import { useEffect } from "react"
import { roomStore } from "@/stores/room"
import { globalStore } from "@/stores/global"
import { t } from "@/i18n"
import { resolvePeerMessage, jsonParse } from "@/utils/helper"
import { ProtocolVersion, ChatCmdType } from "@/utils/agora-rtm-client"
import { useHistory } from "react-router-dom"

export const useRtm = () => {

  const history = useHistory();

  useEffect(() => {
    if (!roomStore.state.rtm.joined) return;
    const rtmClient = roomStore.rtmClient;
    rtmClient.on('ConnectionStateChanged', ({ newState, reason }: { newState: string, reason: string }) => {
      console.log(`newState: ${newState} reason: ${reason}`);
      if (reason === 'LOGIN_FAILURE') {
        globalStore.showToast({
          type: 'rtmClient',
          message: t('toast.login_failure'),
        });
        history.push('/');
        return;
      }
      if (reason === 'REMOTE_LOGIN' || newState === 'ABORTED') {
        globalStore.showToast({
          type: 'rtmClient',
          message: t('toast.kick'),
        });
        history.push('/');
        return;
      }

      if (newState === 'CONNECTED' && reason === 'LOGIN_SUCCESS') {
        roomStore.fetchCurrentRoom()
        .then((me: any) => {
          if (me && me.state === 0) {
            roomStore.exitAll().finally(() => {
              globalStore.showToast({
                type: 'meeting',
                message: t('meeting.need_login')
              })
              history.push('/')
            })
          }
        })
        .catch((err: any) => {
          roomStore.exitAll().finally(() => {
            globalStore.showToast({
              type: 'meeting',
              message: t('meeting.need_login')
            })
            history.push('/')
          })
        })
      }
    });
    rtmClient.on('MessageFromPeer', ({ message: { text }, peerId, props }: { message: { text: string }, peerId: string, props: any }) => {
      const body = resolvePeerMessage(text);

      if (body.version !== ProtocolVersion) return console.warn('Received Mismatched Message')
      roomStore
        .handlePeerMessage(body, peerId)
      // .then(() => {
      // }).catch(console.warn);
    });
    rtmClient.on('ChannelMessage', ({ memberId, message }: { message: { text: string }, memberId: string }) => {
      const { cmd, version, data } = jsonParse(message.text);

      if (version !== ProtocolVersion) {
        console.warn('Received Mismatched Message')
        return
      }

      console.log('ChannelMessage cmd:  ', message, cmd, JSON.stringify(data))
      // TODO: chat message
      // TODO: 更新即时聊天
      if (cmd === ChatCmdType.chat) {
        if (data.userId === roomStore.state.me.userId) return
        if (!roomStore.state.meetingState.drawerChat) {
          roomStore.incrementMessageCount()
        }
        const chatMessage = {
          userName: data.userName,
          text: data.message,
          ts: +Date.now(),
          id: memberId,
          sender: data.userId === roomStore.state.me.userId
        }
        roomStore.updateChannelMessage(chatMessage);
        console.log('[rtmClient] chatMessage ', chatMessage, ' raw Data: ', data);
      }

      // TODO: update room member changed
      // TODO: 更新人员进出
      if (cmd === ChatCmdType.roomMemberChanged) {
        const memberCount = data.total
        const list = data.list
        roomStore.updateRawRoomMember(memberCount, list)
      }

      // TODO: update confState state
      // TODO: 更新房间信息
      if (cmd === ChatCmdType.roomInfoChanged) {
        roomStore.updateRoomInfo({
          muteAllChat: data.muteAllChat,
          muteAllAudio: data.muteAllAudio,
          state: data.state
        })
      }

      // TODO: update room user state
      // TODO: 更新用户状态
      if (cmd === ChatCmdType.roomUserStateChanged) {
        const user = data;
        roomStore.updateRawUserState(user);
      }

      // TODO: 更新白板
      if (cmd === ChatCmdType.shareBoard) {
        roomStore.updateRawShareBoardUsers(
          data.shareBoard,
          data.shareBoardUsers,
          data.createBoardUserId
        )
      }
      // TODO: 更新屏幕共享
      if (cmd === ChatCmdType.screenShare) {
        roomStore.updateRawShareScreenUsers(
          data.shareScreen,
          data.shareScreenUsers,
        )
      }

      if (cmd === ChatCmdType.hostChanged) {
        roomStore.updateHostChange(
          data
        )
      }

      if (cmd === ChatCmdType.kickOut) {
        roomStore.updateKickOutChange(
          data
        )
      }
    });
    return () => {
      rtmClient.removeAllListeners();
    }
  }, [roomStore.state.rtm.joined]);
}