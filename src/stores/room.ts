import { SessionKeyIdentifier, userKeyIdentifier } from '@/utils/config';
import { PeerCmdType, MeetingMessageType, PeerCmdMediaState } from '@/utils/agora-rtm-client';
import { ChatMessage, AgoraStream, AgoraMediaStream } from '@/utils/types';
import { Subject } from 'rxjs';
import { Map, Set, List } from 'immutable';
import AgoraRTMClient, { RoomMessage, CoVideoType } from '@/utils/agora-rtm-client';
import { AgoraWebClient } from '@/utils/agora-web-client';
import GlobalStorage from '@/utils/custom-storage';
import { t } from '@/i18n';
import { confApi, EntryParams } from '@/services/meeting-api';
import { RoomKeyIdentifier } from '@/utils/config';
import { globalStore } from './global';

function transformAgoraUser(user: any) {
  const {
    enableChat,
    enableVideo,
    enableAudio,
    state,
    ...attrs
  } = user

  return {
    ...attrs,
    chat: enableChat,
    video: enableVideo,
    audio: enableAudio,
  }
}

export interface MediaState {
  useMicrophone: number
  useCamera: number
}

export interface AgoraUser {
  uid: string
  userName: string
  role: number
  video: number
  audio: number
  chat: number
  grantBoard: number
  grantScreen: number
  userId: string // 仅用于服务端
  screenId: string //仅用于屏幕共享
}

export interface Me extends AgoraUser {
  roomUuid: string
  roomName: string
  userUUid: string
  userToken: string
  rtmToken: string
  rtcToken: string
  screenToken?: string
  appID: string
}

export interface ConfState {
  roomId: string
  roomUuid: string
  roomName: string

  // 频道名
  channelName: string

  // 全员禁言
  muteAllChat: number
  muteAllAudio: number
  // 开始时间
  startTime: number


  appID: string

  boardId: string
  boardToken: string

  shareBoard: number
  shareScreen: number
  createBoardUserId: string
}


export type MediaDeviceState = {
  microphoneIdx: number
  cameraIdx: number
  // useCamera: number
  // useMicrophone: number
}

export type PeerUser = {
  userId: string
  userName: string
  type: number
  action: number
}

export type NoticeStateType = {
  userId: string
  userName: string
  role: number
  type: number
  state: number
} 

export type meetingState = {
  drawerChat: boolean
  drawerMember: boolean
  showShareMenu: boolean
  peerUser: PeerUser
}

export type RtcState = {
  published: boolean
  joined: boolean
  users: Set<number>
  shared: boolean
  localStream: AgoraStream | null
  localSharedStream: AgoraStream | null
  largeScreenUserId: number
  remoteStreams: Map<string, AgoraStream>
}

export type SessionInfo = {
  userName: string,
  password: string,
  roomName: string
}

export type RoomUsers = {
  onlineUsers: number
  hosts: Map<string, AgoraUser>
  shareBoardUsers: Map<string, AgoraUser>
  shareScreenUsers: Map<string, AgoraUser>
  audiences:  Map<string, AgoraUser>
}

export type RoomState = {
  me: Me,
  messageCount: number,
  users: RoomUsers,
  // users: Map<string, AgoraUser>,
  confState: ConfState,
  mediaState: MediaState,
  mediaDevice: MediaDeviceState,
  meetingState: meetingState,
  messages: List<ChatMessage>,
  rtc: RtcState,
  rtm: {
    joined: boolean
  },
  sessionInfo: SessionInfo
  inviteDialog: boolean
  inviteDialogBottom: boolean
  maximum: boolean
}

export class RoomStore {
  private subject: Subject<RoomState> | null;
  public _state: RoomState;

  get state() {
    return this._state;
  }

  set state(newState) {
    this._state = newState;
  }
  public readonly defaultState: RoomState = Object.freeze({
    messageCount: 0,
    me: {
      uid: '',
      userName: '',
      role: '',
      video: '',
      audio: '',
      chat: '',
      grantBoard: '',
      grantScreen: '',
      userId: '',
      screenId: '',
      
      roomName: '',
      userToken: '',
      rtmToken: '',
      rtcToken: '',
      screenToken: '',
      appID: '',
      roomUuid: '',
      userUuid: '',
    },
    users: {
      onlineUsers: 0,
      hosts: Map<string, AgoraUser>(),
      shareBoardUsers: Map<string, AgoraUser>(),
      shareScreenUsers: Map<string, AgoraUser>(),
      audiences: Map<string, AgoraUser>(),
    },
    confState: {
      appID: '',
      roomName: '',
      roomId: '',
      shareBoardUsers: Map<string, AgoraUser>(),
      shareScreenUsers: Map<string, AgoraUser>(),
      hosts: Map<string, AgoraUser>(),
      onlineUsers: '',

      boardId: '',
      boardToken: '',
      
      channelName: '',
      muteAllChat: 0,
      muteAllAudio: 0,
      startTime: 0,

      shareBoard: 0,
      shareScreen: 0,
      createBoardUserId: '',
    },
    inviteDialog: false,
    inviteDialogBottom: false,
    mediaState: {
      useCamera: 0,
      useMicrophone: 0,
    },
    mediaDevice: {
      microphoneIdx: 0,
      cameraIdx: 0,
    },
    meetingState: {
      drawerChat: false,
      drawerMember: false,
      showShareMenu: false,
      peerUser: {
        userId: '',
        userName: '',
        type: 0,
        action: 0,
      }
    },
    rtm: {
      joined: false,
    },
    rtc: {
      published: false,
      joined: false,
      users: Set<number>(),
      shared: false,
      localStream: null,
      localSharedStream: null,
      largeScreenUserId: 0,
      remoteStreams: Map<string, AgoraMediaStream>()
    },
    maximum: false,
    messages: List<ChatMessage>(),
    ...GlobalStorage.read(RoomKeyIdentifier),
    ...GlobalStorage.readLocalStorage(SessionKeyIdentifier),
    sessionInfo: {
      ...GlobalStorage.readSessionInfo()
    },
  });

  public windowId: number = 0;

  public rtmClient: AgoraRTMClient;
  public rtcClient: AgoraWebClient;
  public microphoneList: any[];
  public cameraList: any[];

  constructor() {
    this.subject = null;
    this._state = {
      ...this.defaultState
    };
    this.rtmClient = new AgoraRTMClient();
    this.rtcClient = new AgoraWebClient({roomStore: this});
    this.microphoneList = []
    this.cameraList = []
  }

  get currentMicrophone (): string {
    let microphoneDeviceId = ''
    if (this.microphoneList.length && this.microphoneList[this.state.mediaDevice.microphoneIdx]) {
      microphoneDeviceId = this.microphoneList[this.state.mediaDevice.microphoneIdx]
    }
    return microphoneDeviceId
  }


  get currentCamera (): string {
    let cameraDeviceId = ''
    if (this.cameraList.length && this.cameraList[this.state.mediaDevice.cameraIdx]) {
      cameraDeviceId = this.cameraList[this.state.mediaDevice.cameraIdx]
    }
    return cameraDeviceId
  }

  initialize() {
    this.subject = new Subject<RoomState>();
    this.state = {
      ...this.defaultState,
    }
    this.subject.next(this.state);
  }

  subscribe(updateState: any) {
    this.initialize();
    this.subject && this.subject.subscribe(updateState);
  }

  unsubscribe() {
    this.subject && this.subject.unsubscribe();
    this.subject = null;
  }

  commit(state: RoomState) {
    this.subject && this.subject.next(state);
  }

  updateRoomState(me: any, roomInfo: any) {
    this.state = {
      ...this.state,
      me,
      rtm: {
        joined: true,
      },
      users: {
        ...this.state.users,
        onlineUsers: roomInfo.onlineUsers,
        hosts: roomInfo.hosts,
        shareBoardUsers: roomInfo.shareBoardUsers,
        shareScreenUsers: roomInfo.shareScreenUsers,
        audiences: roomInfo.audiences,
      },
      confState: {
        createBoardUserId: roomInfo.createBoardUserId,
        roomId: roomInfo.roomId,
        roomUuid: roomInfo.roomUuid,
        roomName: roomInfo.roomName,
        channelName: roomInfo.channelName,
                
        muteAllChat: roomInfo.muteAllChat,
        muteAllAudio: roomInfo.muteAllAudio,

        // 用户
        startTime: roomInfo.startTime,
        appID: roomInfo.appID,

        // 白板
        boardId: roomInfo.boardId,
        boardToken: roomInfo.boardToken,
        
        shareBoard: roomInfo.shareBoard,
        shareScreen: roomInfo.shareScreen,
      }
    }

    this.commit(this.state)
  }

  async LoginToRoom(payload: EntryParams) {
    const {
      me,
      roomInfo,
    } = await confApi.Login(payload)

    await this.rtmClient.login(roomInfo.appID, `${me.uid}`, me.rtmToken)
    await this.rtmClient.join(roomInfo.channelName)

    this.updateRoomState(
      me,
      roomInfo
    )
  }

  setUseCamera(val: number) {
    this.state = {
      ...this.state,
      mediaState: {
        ...this.state.mediaState,
        useCamera: val,
      }
    }
    this.commit(this.state)
  }

  setUseMicrophone(val: number) {
    this.state = {
      ...this.state,
      mediaState: {
        ...this.state.mediaState,
        useMicrophone: val
      }
    }
    this.commit(this.state)
  }

  async getRoomStateBy(roomId: string) {
    let {
      roomUuid,
      roomName,
      channelName,
      password,
    } = await confApi.getSessionInfoBy(roomId)

    const result = {
      roomUuid,
      roomName,
      channelName,
      password,
    }

    this.state = {
      ...this.state,
      sessionInfo: {
        ...this.state.sessionInfo,
        roomName,
        userName: '',
        password,
      }
    }
    this.commit(this.state)
  }

  resetMessageCount() {
    this.setMessageCount(0)
  }

  incrementMessageCount() {
    this.setMessageCount(this.state.messageCount+1)
  }

  setMessageCount(num: number) {
    this.state = {
      ...this.state,
      messageCount: num
    }
    this.commit(this.state)
  }

  async exitRoom () {
    const roomId = this.state.confState.roomId
    const userId = this.state.me.userId
    if (roomId) {
      await confApi.exitRoom(roomId, userId)
    }
  }

  async endMeeting () {
    const roomId = this.state.confState.roomId
    if (roomId) {
      await confApi.updateGlobalRoomState(roomId, {
        state: 0
      })
    }
  }

  async sendChannelMessage(payload: any) {
    await confApi.sendChannelMessage({
      roomId: this.state.confState.roomId,
      message: payload.message,
      type: 1,
    })
  }

  updateChannelMessage (msg: any) {
    this.state = {
      ...this.state,
      messages: this.state.messages.push(msg)
    }
    this.commit(this.state)
  }

  async handlePeerData(cmd: any, type: number, val: number) {
    const types = ['unknown', 'audio', 'video', 'board']
    const mediaType = types[type] as string

    const {
      userId, 
      userName,
    } = this.state.meetingState.peerUser

    console.log("userId, ", userId, " userName, ", userName)

    if (cmd === PeerCmdType.Approver) {
      if (mediaType === 'audio') {
        await this.updateUserMediaState(userId, MeetingMessageType.audio, !!val)
      }

      if (mediaType === 'video') {
        await this.updateUserMediaState(userId, MeetingMessageType.video, !!val)
      }

      if (mediaType === 'board') {
        await this.updateUserMediaState(userId, MeetingMessageType.board, !!val)
      }
    }

    if (cmd === PeerCmdType.Applicant) {
      if (mediaType === 'audio') {
        await this.updateUserMediaState(this.state.me.userId, MeetingMessageType.audio, !!val)
      }

      if (mediaType === 'video') {
        await this.updateUserMediaState(this.state.me.userId, MeetingMessageType.video, !!val)
      }

      if (mediaType === 'board') {
        await this.updateUserMediaState(this.state.me.userId, MeetingMessageType.board, !!val)
      }
    }
  }

  // async rejectOperate(cmd: any, type: number, action: number) {
  //   const roomId = this.state.confState.roomId
  //   const userId = this.state.me.userId
  //   const role = this.state.me.role

  //   if (role === 1) {

  //   } else {

  //   }
  // }

  // async acceptOperate(cmd: any, type: number) {
  //   await this.handlePeerData(cmd, type, 1)
  // }

  async audienceAcceptHostInvite() {
    const peerUser = this.state.meetingState.peerUser

    const {
      type,
    } = peerUser

    if (type === MeetingMessageType.audio){
      await this.updateLocalAudioState(true)
    }

    if (type === MeetingMessageType.video) {
      await this.updateLocalVideoState(true)
    }

    if (type === MeetingMessageType.board) {
      await this.updateLocalBoardState(true)
    }

    this.setPeerUser({
      type: 0,
      userId: '',
      action: 0,
      userName: ''
    })
  }

  async hostAcceptApply() {
    const peerUser = this.state.meetingState.peerUser

    const {
      type,
      userId
    } = peerUser

    if (type === MeetingMessageType.board) {
      await this.setGrantBoard(userId, 1)
    } else {
      await this.updateUserMediaState(userId, type, true)
    }

    this.setPeerUser({
      type: 0,
      userId: '',
      action: 0,
      userName: ''
    })
  }

  async audienceRejectHostInvite() {
    const roomId = this.state.confState.roomId
    const peerUser = this.state.meetingState.peerUser

    const {
      type,
      userId,
    } = peerUser

    if (type === MeetingMessageType.audio){
      await confApi.sendApply(roomId, userId, {
        type: MeetingMessageType.audio,
        action: 2,
      })
    }

    if (type === MeetingMessageType.video) {
      await confApi.sendApply(roomId, userId, {
        type: MeetingMessageType.video,
        action: 2,
      })
    }

    if (type === MeetingMessageType.board) {
      await confApi.sendApply(roomId, userId, {
        type: MeetingMessageType.board,
        action: 2,
      })
    }

    this.setPeerUser({
      type: 0,
      userId: '',
      action: 0,
      userName: ''
    })
  }

  async hostRejectAudienceInvite() {
    const roomId = this.state.confState.roomId
    const peerUser = this.state.meetingState.peerUser

    const {
      type,
      userId,
    } = peerUser

    if (type === MeetingMessageType.audio){
      await confApi.sendInvite(roomId, userId, {
        type: MeetingMessageType.audio,
        action: 2,
      })
    }

    if (type === MeetingMessageType.video) {
      await confApi.sendInvite(roomId, userId, {
        type: MeetingMessageType.video,
        action: 2,
      })
    }

    if (type === MeetingMessageType.board) {
      await confApi.sendInvite(roomId, userId, {
        type: MeetingMessageType.board,
        action: 2,
      })
    }
    this.setPeerUser({
      type: 0,
      userId: '',
      action: 0,
      userName: ''
    })
  }

  updateKickOutChange(data: any) {
    const {
      hostUserId,
      hostUserName,
      userId,
    } = data

    const isMe = this.state.me.userId === userId
    if (isMe) {
      try {
        this.rtmClient.exit()
      } catch(err) {
        console.error('rtmExit, when kicked', JSON.stringify(err))
      }
      try {
        this.rtcClient.exit()
      } catch (err) {
        console.error('rtcExit, when kicked', JSON.stringify(err))
      }
      confApi.userToken = '' 
      confApi.nextId = 0
      globalStore.showDialog({
        type: 'kickedOut',
        message: t('meeting.kicked_by', {reason: `${hostUserName}`}),
        mask: false,
        showCancel: false,
      })
    } else {
      console.warn(`${userId} kicked by ${hostUserName} ${hostUserId}`)
    }
  }


  updateHostChange(lists: AgoraUser[]) {

    const offlineUserIds = lists
      .filter(({state}: any) => state === 0)
      .map((user: any) => user.userId)

    const onlineUsers = lists
      .filter(({state}: any) => state === 1)

    const rawUsers = onlineUsers.map(
      ({roomId, ...user}: any) => transformAgoraUser(user)
    )

    const rawHosts = rawUsers.filter((it: any) => it.role === 1)
    const rawAudiences = rawUsers.filter((it: AgoraUser) => it.role === 2)

    const removeSnapShot = this.removeUsers(offlineUserIds)

    const finalState = this.updateRole(rawHosts, rawAudiences, removeSnapShot)

    const me = this.state.me
    const currentUser: AgoraUser = rawUsers.find((user: any) => user.userId === me.userId)

    if (currentUser) {
      this.state = {
        ...this.state,
        me: {
          ...me,
          ...currentUser
        },
        users: {
          ...this.state.users,
          ...finalState
        }
      }
    } else {
      this.state = {
        ...this.state,
        users: {
          ...this.state.users,
          ...finalState
        }
      }
    }

    this.commit(this.state)
  }

  // TODO: 点对点消息
  async handlePeerMessage(body: any, peerId: string) {
    const {cmd, data: {userId, userName, role, ...res}} = body
    console.log(`cmd: ${cmd}, res: ${JSON.stringify(res)} userId: ${userId}, userName: ${userName}`)
    const peerUserId = this.state.meetingState.peerUser.userId
    if (peerUserId) {
      return console.warn('you already received peer userId: ', peerUserId)
    }

    if (cmd === PeerCmdType.Approver) {
      this.setPeerUser({
        userId: userId,
        userName: userName,
        type: res.type,
        action: res.action,
      })

      const isInvite = res.action === 1 ? true : false
      const dialogType = isInvite ? 'hostInvite' : 'hostReject'

      let dialogMsgType = 'unknown'

      switch (res.type) {
        case MeetingMessageType.audio: {
          dialogMsgType = isInvite ? 'host_invite_enable_audio' : 'user_reject_enable_audio'
          break
        }
        case MeetingMessageType.video: {
          dialogMsgType = isInvite ? 'host_invite_enable_video' : 'user_reject_enable_video'
          break
        }
        case MeetingMessageType.board: {
          dialogMsgType = isInvite ? 'host_invite_enable_board' : 'user_reject_enable_board'
          break
        }
      }

      const isReject = dialogMsgType.match(/reject/)

      let dialogMessage = `meeting.operate_notice.${dialogMsgType}`

      const dialogTextMessage = isInvite ? t(`${dialogMessage}`) : t(`${dialogMessage}`, {reason: t("meeting.host")})

      globalStore.showDialog({
        type: dialogType,
        message: dialogTextMessage,
        mask: false,
        confirmText: isReject ? '确认' : '同意',
        cancelText: isReject ? '' : '拒绝',
        showCancel: isReject ? false : true,
        showConfirm: true
      })

      return
    }

    if (cmd === PeerCmdType.Applicant) {
      this.setPeerUser({
        userId: userId,
        userName: userName,
        type: res.type,
        action: res.action,
      })
      const isApply = res.action === 1 ? true : false
      const dialogType = isApply ? 'audienceApply' : 'audienceReject'

      let dialogMsgType = 'unknown'

      switch (res.type) {
        case MeetingMessageType.audio: {
          dialogMsgType = isApply ? 'user_apply_enable_audio' : 'user_reject_enable_audio'
          break
        }
        case MeetingMessageType.video: {
          dialogMsgType = isApply ? 'user_apply_enable_video' : 'user_reject_enable_video'
          break
        }
        case MeetingMessageType.board: {
          dialogMsgType = isApply ? 'user_apply_enable_board' : 'user_reject_enable_board'
          break
        }
      }

      const isReject = dialogMsgType.match(/reject/)

      let dialogMessage = `meeting.operate_notice.${dialogMsgType}`

      const dialogTextMessage = t(`${dialogMessage}`, {reason: userName})

      globalStore.showDialog({
        type: dialogType,
        message: dialogTextMessage,
        mask: false,
        showConfirm: true,
        confirmText: isReject ? '确定' : '同意',
        showCancel: isReject ? false : true,
        cancelText: isReject ? '' : '拒绝',
      })

      return
    }

    if (cmd === PeerCmdType.Notice) {
      this.showMeetingMediaStateChanged({
        userId: userId,
        userName: userName,
        role: role,
        type: res.type,
        state: res.state,
      })
    }
  }

  showMeetingMediaStateChanged({userId, userName, type, state, role}: NoticeStateType) {
    let mediaType = 'unknown'
    const mediaTypeMap: {[key: number]: string} = {
      [MeetingMessageType.audio]: 'audio',
      [MeetingMessageType.video]: 'video',
      [MeetingMessageType.board]: 'board',
      [MeetingMessageType.chat]: 'chat',
    }

    if (mediaTypeMap[type] as string) {
      mediaType = mediaTypeMap[type] as string
    }

    const stateTypeMap: {[key: number]: string} = {
      [PeerCmdMediaState.disable]: 'disable',
      [PeerCmdMediaState.enable]: 'enable',
    }

    let mediaState = 'unknown'

    if (stateTypeMap[state] as string) {
      mediaState = stateTypeMap[state]
    }

    let answerName = userName

    // if (mediaType === 'board') {
    //   answerName = t('meeting.Owner')
    // } else {
    //   if (role === 1) {
    //     answerName = t('meeting.Host')
    //   }
    // }

    const toastMessage = t(`meeting.state_changed.${mediaType}.${mediaState}`, {reason: answerName})

    globalStore.showDialog({
      type: 'meetingStateChanged',
      message: toastMessage,
      mask: false,
      showCancel: false,
    })
  }

  async updateRawRoomMember(count: number, list: any[]) {
    const newUsers = list
      .filter(item => item.state === 1)
      .reduce((acc: AgoraUser[], user: any) => {
        const item = transformAgoraUser(user)
        acc.push(item)
        return acc
      }, [])

    const me = this.state.me

    const leftUsers = list.filter(item => item.state === 0)

    leftUsers
    .filter((user: AgoraUser) => user.userId !== me.userId)
    .forEach((user: AgoraUser) => {
      globalStore.showToast({
        type: 'left',
        message: t(`meeting.someone.left`, {reason: user.userName}),
        duration: 1500,
        internal: true
      })
    })

    newUsers
    .filter((user: AgoraUser) => user.userId !== me.userId)
    .forEach((user: AgoraUser) => {
      globalStore.showToast({
        type: 'joined',
        message: t(`meeting.someone.joined`, {reason: user.userName}),
        duration: 1500,
        internal: true
      })
    })

    const leaveUserUserIds = leftUsers.map(item => item.userId)

    console.log("count", JSON.stringify(list), JSON.stringify(newUsers))
    console.log('leftUsers',JSON.stringify(leftUsers))
    console.log('leaveUserUserIds',JSON.stringify(leaveUserUserIds))

    const snapShot = this.removeUsers(leaveUserUserIds)

    const finalState = this.upsertUsers(newUsers, snapShot)

    this.state = {
      ...this.state,
      users: {
        ...this.state.users,
        onlineUsers: count,
        ...finalState
      }
    }

    this.commit(this.state)
  }

  async updateRoomInfo(payload: any) {
    if (payload.state === 0) {
      try {
        await this.rtmClient.exit()
      } catch(err) {
        console.error('rtmExit, when kicked', JSON.stringify(err))
      }
      try {
        await this.rtcClient.exit()
      } catch (err) {
        console.error('rtcExit, when kicked', JSON.stringify(err))
      }
      confApi.userToken = '' 
      confApi.nextId = 0
      this.setPeerUser({
        userId: '',
        userName: '',
        type: 0,
        action: 0
      })
      globalStore.showDialog({
        type: 'meetingAlreadyEnded',
        message: t('meeting.end_meeting'),
        mask: false,
        showCancel: false
      })
    }

    const me = this.state.me

    const muteAllChat = payload.hasOwnProperty('muteAllChat') ? payload.muteAllChat : this.state.confState.muteAllChat
    const muteAllAudio = payload.hasOwnProperty('muteAllAudio') ? payload.muteAllAudio : this.state.confState.muteAllAudio
    const startTime = payload.hasOwnProperty('startTime') ? payload.startTime : this.state.confState.startTime

    if (payload.hasOwnProperty('muteAllAudio') && payload.muteAllAudio > 0) {
      const audio = 0

      let prevAudiences = this.state.users.audiences

      prevAudiences = prevAudiences.reduce((acc: Map<string, AgoraUser>, it: AgoraUser) => {
        acc = acc.set(`${it.uid}`, {
          ...it,
          audio: 0
        })
        return acc
      }, prevAudiences)

      this.state = {
        ...this.state,
        confState: {
          ...this.state.confState,
          muteAllChat,
          muteAllAudio,
          startTime,
        },
        me: {
          ...me,
          audio: me.role === 1 ? me.audio : audio
        },
        users: {
          ...this.state.users,
          audiences: prevAudiences,
        }
      }
      this.commit(this.state)
      return
    }
     else {
      this.state = {
        ...this.state,
        confState: {
          ...this.state.confState,
          muteAllChat,
          muteAllAudio,
          startTime,
        }
      }
      this.commit(this.state)
      return
    }
  }

  setPeerUser(user: Pick<PeerUser, 'userId' | 'userName' | 'type' | 'action'>) {
    this.state = {
      ...this.state,
      meetingState: {
        ...this.state.meetingState,
        peerUser: user
      }
    }
    this.commit(this.state)
  }

  setDrawerChat(val: boolean) {

    if (val) {
      this.state = {
        ...this.state,
        meetingState: {
          ...this.state.meetingState,
          drawerChat: val
        },
        messageCount: 0
      }
    } else {
      this.state = {
        ...this.state,
        meetingState: {
          ...this.state.meetingState,
          drawerChat: val
        },
      }
    }
    this.commit(this.state)
  }

  setDrawerMember(val: boolean) {
    this.state = {
      ...this.state,
      meetingState: {
        ...this.state.meetingState,
        drawerMember: val
      }
    }
    this.commit(this.state)
  }

  async startWebScreenShare() {
    const webClient = this.rtcClient as AgoraWebClient
    try {
      const roomId = this.state.confState.roomId
      const {screenToken} = await confApi.refreshToken(roomId);
      const appId = this.state.confState.appID
      const channelName = this.state.confState.channelName
      const {screenId} = this.state.me
      await webClient.startScreenShare({
        uid: +screenId,
        token: screenToken,
        channel: channelName,
        appId
      })
      // add screen client listener
      // 监听屏幕共享主要的事件
      webClient.shareClient.on('onTokenPrivilegeWillExpire', (evt: any) => {
        // WARN: IF YOU ENABLED APP CERTIFICATE, PLEASE SIGN YOUR TOKEN IN YOUR SERVER SIDE AND OBTAIN IT FROM YOUR OWN TRUSTED SERVER API
        const newToken = '';
        webClient.shareClient.renewToken(newToken);
      });
      webClient.shareClient.on('onTokenPrivilegeDidExpire', (evt: any) => {
        // WARN: IF YOU ENABLED APP CERTIFICATE, PLEASE SIGN YOUR TOKEN IN YOUR SERVER SIDE AND OBTAIN IT FROM YOUR OWN TRUSTED SERVER API
        const newToken = '';
        webClient.shareClient.renewToken(newToken);
      });
      webClient.shareClient.on('stopScreenSharing', (evt: any) => {
        console.log('stop screen share', evt);
        this.stopWebScreenShare().then(() => {
          globalStore.showToast({
            message: t('toast.canceled_screen_share'),
            type: 'notice'
          });
        }).catch(console.warn).finally(() => {
          console.log('[agora-web] stop share');
        })
      })
    } catch(err) {
      if (webClient.shareClient) {
        webClient.shareClient.off('onTokenPrivilegeWillExpire', (evt: any) => {})
        webClient.shareClient.off('onTokenPrivilegeDidExpire', (evt: any) => {})
        webClient.shareClient.off('stopScreenSharing', (evt: any) => {})
      }
      if (err.type === 'error' && err.msg === 'NotAllowedError') {
        globalStore.showToast({
          message: t('toast.canceled_screen_share'),
          type: 'notice'
        });
      }
      if (err.type === 'error' && err.msg === 'PERMISSION_DENIED') {
        globalStore.showToast({
          message: t('toast.screen_sharing_failed', {reason: err.msg}),
          type: 'notice'
        });
      }
      throw err
    }
  }

  async stopWebScreenShare() {
    const webClient = this.rtcClient as AgoraWebClient
    if (webClient.shared) {
      await webClient.stopScreenShare()
      this.removeLocalSharedStream();
    }
  }

  async startRecording() {

  }

  async stopRecording() {

  }

  async fetchAndLoginRTM () {
    const roomId = this.state.confState.roomId
    const userToken = this.state.me.userToken
    const {
      me, 
      roomInfo
    } = await confApi.getRoomInfo(roomId, userToken)

    await this.rtmClient.login(roomInfo.appID, `${me.uid}`, me.rtmToken)
    await this.rtmClient.join(roomInfo.channelName)
    this.updateRoomState(me, roomInfo)
    return me
  }

  async fetchCurrentRoom() {
    const roomId = this.state.confState.roomId
    const userToken = this.state.me.userToken
    const {
      me, 
      roomInfo
    } = await confApi.getRoomInfo(roomId, userToken)
    this.updateRoomState(me, roomInfo)
    return me
  }

  async fetchAudienceList() {

  }

  async quitMeeting () {
    confApi.nextId = 0
    await this.exitRoom()
    await this.exitAll()
  }

  async exitAllAndEndMeeting() {
    confApi.nextId = 0
    await this.endMeeting()
    await this.exitAll()
  }

  async exitAll() {
    try {
      try {
        await this.rtmClient.exit();
      } catch (err) {
        console.warn(err);
      }
      try {
        await this.rtcClient.exit();
      } catch (err) {
        console.warn(err);
      }
    } finally {
      const oldState = this.state
      this.state = {
        ...this.defaultState,
        sessionInfo: {
          ...oldState.sessionInfo
        },
        mediaState: {
          ...oldState.mediaState,
        },
        mediaDevice: {
          ...oldState.mediaDevice,
        },
      }
      this.commit(this.state);
    }
  }

  setRTCJoined(joined: boolean) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        joined
      }
    }
    this.commit(this.state);
  }

  addLocalStream(stream: AgoraStream) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        localStream: stream
      }
    }
    this.commit(this.state);
  }

  toggleShareMenu() {
    this.state = {
      ...this.state,
      meetingState: {
        ...this.state.meetingState,
        showShareMenu: !this.state.meetingState.showShareMenu
      }
    }
    this.commit(this.state)
  }

  removeLocalStream() {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        localStream: null,
        localSharedStream: null
      }
    }
    console.log("removeLocalStream>>")
    this.commit(this.state);
  }

  addLocalSharedStream(stream: any) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        localSharedStream: stream
      }
    }
    this.commit(this.state);
  }

  removeLocalSharedStream() {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        localSharedStream: null
      }
    }
    this.commit(this.state);
  }

  addRTCUser(uid: number) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        users: this.state.rtc.users.add(uid),
      }
    }
    this.commit(this.state);
  }

  removePeerUser(uid: number) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        users: this.state.rtc.users.delete(uid),
      }
    }
    this.commit(this.state);
  }

  addRemoteStream(stream: AgoraStream) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        remoteStreams: this.state.rtc.remoteStreams.set(`${stream.streamID}`, stream)
      }
    }
    this.commit(this.state);
  }

  removeRemoteStream(uid: number) {
    const remoteStream = this.state.rtc.remoteStreams.get(`${uid}`);
    if (remoteStream && remoteStream.stream && remoteStream.stream.isPlaying) {
      remoteStream.stream.isPlaying() && remoteStream.stream.stop();
    }

    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        remoteStreams: this.state.rtc.remoteStreams.delete(`${uid}`)
      }
    }
    this.commit(this.state);
  }

  async toggleShare (type: 'shareBoard' | 'shareScreen') {
    let nextState = 0
    if (type === 'shareBoard') {
      nextState = this.state.confState.shareBoard ? 0 : 1
    }

    if (type === 'shareScreen') {
      nextState = this.state.confState.shareScreen ? 0 : 1
    }
    await this.updateShareState(type, !!nextState)
  } 

  async updateShareState(type: 'shareBoard' | 'shareScreen', val: boolean) {
    const roomId = this.state.confState.roomId
    const userId = this.state.me.userId

    let {
      boardId,
      boardToken
    } = this.state.confState

    if (type === 'shareBoard') {
      const res = await confApi.getWhiteboardBy(roomId)
      boardId = res.boardId
      boardToken = res.boardToken
      await confApi.updateShareBoard(roomId, userId, +val)
    }

    if (type === 'shareScreen') {
      await confApi.updateShareScreen(roomId, userId, +val)
    }

    this.state = {
      ...this.state,
      confState: {
        ...this.state.confState,
        [`${type}`]: +val,
        boardId: boardId ? boardId : '',
        boardToken: boardToken ? boardToken : '',
      },
      meetingState: {
        ...this.state.meetingState,
        showShareMenu: false
      }
    }
    this.commit(this.state)
  }

  updateRawUserState(rawUser: any) {
    if (rawUser && rawUser.state === 1) {
      const user = transformAgoraUser(rawUser)
      const newState = this.state

      if (user.userId === this.state.me.userId) {
        const newUsersState = this.upsertUsers([user], this.state.users)

        this.state = {
          ...this.state,
            me: {
            ...newState.me,
            role: user.role,
            userName: user.userName,
            chat: user.chat,
            video: user.video,
            audio: user.audio,
          },
          users: {
            ...this.state.users,
            ...newUsersState,
          }
        }
        // this.inspect(newUsersState)
        this.commit(this.state)
      } else {
        const newUsersState = this.upsertUsers([user], this.state.users)
        this.state = {
          ...this.state,
          users: {
            ...this.state.users,
            ...newUsersState,
          }
        }
        // this.inspect(newUsersState)
        this.commit(this.state)
      }
    }
  }

  async updateRawShareBoardUsers(
    shareBoard: any,
    shareBoardUsers: any[],
    createBoardUserId: string,
  ) {
    const onlineRawUsers = shareBoardUsers.reduce((acc: Map<string, AgoraUser>, rawUser: any) => {
      const {roomId, ...user} = rawUser
      acc = acc.set(`${user.uid}`, {
        ...user
      })
      return acc
    }, Map<string, AgoraUser>())
 
    const me = this.state.me

    const containMe = onlineRawUsers.get(`${me.uid}`)

    let prevAudiences = this.state.users.audiences

    let prevHosts = this.state.users.hosts

    if (+shareBoard === 0) {
      prevAudiences = prevAudiences.reduce((acc: Map<string, AgoraUser>, user: AgoraUser) => {
        acc = acc.set(`${user.uid}`, {
          ...user,
          grantBoard: 0
        })
        return acc
      }, this.state.users.audiences)

      prevHosts = prevHosts.reduce((acc: Map<string, AgoraUser>, user: AgoraUser) => {
        acc = acc.set(`${user.uid}`, {
          ...user,
          grantBoard: 0
        })
        return acc
      }, this.state.users.hosts)
    } else {
      prevAudiences = prevAudiences.reduce((acc: Map<string, AgoraUser>, user: AgoraUser) => {
        const sharedUser = onlineRawUsers.get(`${user.uid}`)
        acc = acc.set(`${user.uid}`, {
          ...user,
          grantBoard: sharedUser ? 1 : 0
        })
        return acc
      }, this.state.users.audiences)
      
      prevHosts = prevHosts.reduce((acc: Map<string, AgoraUser>, user: AgoraUser) => {
        const sharedUser = onlineRawUsers.get(`${user.uid}`)
        acc = acc.set(`${user.uid}`, {
          ...user,
          grantBoard: sharedUser ? 1 : 0
        })
        return acc
      }, this.state.users.hosts)
    }

    this.state = {
      ...this.state,
      me: {
        ...this.state.me,
        grantBoard: containMe ? 1 : 0,
      },
      users: {
        ...this.state.users,
        audiences: prevAudiences,
        hosts: prevHosts,
        shareBoardUsers: onlineRawUsers,
      },
      confState: {
        ...this.state.confState,
        shareBoard: +shareBoard,
        createBoardUserId,
      }
    }

    this.commit(this.state)
  }

  updateRawShareScreenUsers(
    shareScreen: any,
    shareScreenUsers: any[]
  ) {
    const onlineRawUsers = shareScreenUsers.reduce((acc: Map<string, AgoraUser>, rawUser: any) => {
      const {roomId, ...user} = rawUser
      acc = acc.set(`${user.uid}`, {
        ...user
      })
      return acc
    }, Map<string, AgoraUser>())
 
    const me = this.state.me

    const containMe = onlineRawUsers.get(`${me.uid}`)

    let prevAudiences = this.state.users.audiences

    let prevHosts = this.state.users.hosts

    if (+shareScreen === 0) {
      prevAudiences = prevAudiences.reduce((acc: Map<string, AgoraUser>, user: AgoraUser) => {
        acc = acc.set(`${user.uid}`, {
          ...user,
          grantScreen: 0
        })
        return acc
      }, this.state.users.audiences)

      prevHosts = prevHosts.reduce((acc: Map<string, AgoraUser>, user: AgoraUser) => {
        acc = acc.set(`${user.uid}`, {
          ...user,
          grantScreen: 0
        })
        return acc
      }, this.state.users.hosts)
    } else {
      prevAudiences = prevAudiences.reduce((acc: Map<string, AgoraUser>, user: AgoraUser) => {
        const sharedUser = onlineRawUsers.get(`${user.uid}`)
        acc = acc.set(`${user.uid}`, {
          ...user,
          grantScreen: sharedUser ? 1 : 0
        })
        return acc
      }, this.state.users.audiences)

      prevHosts = prevHosts.reduce((acc: Map<string, AgoraUser>, user: AgoraUser) => {
        const sharedUser = onlineRawUsers.get(`${user.uid}`)
        acc = acc.set(`${user.uid}`, {
          ...user,
          grantScreen: sharedUser ? 1 : 0
        })
        return acc
      }, this.state.users.hosts)
    }


    this.state = {
      ...this.state,
      me: {
        ...this.state.me,
        grantScreen: containMe ? 1 : 0,
      },
      users: {
        ...this.state.users,
        audiences: prevAudiences,
        hosts: prevHosts,
        shareScreenUsers: onlineRawUsers,
      },
      confState: {
        ...this.state.confState,
        shareScreen: +shareScreen,
      }
    }
    this.commit(this.state)
  }

  async hostSendInvite(userId: string, type: MeetingMessageType, val: number) {
    const roomId = this.state.confState.roomId
    const muteAllAudio = this.state.confState.muteAllAudio
    const isMe = userId === this.state.me.userId
    const isHost = this.state.me.role === 1
    // TODO: 主持人身份并且不是本人时打开操作邀请
    if (!isMe && isHost) {
        // 申请打开媒体状态
      await confApi.sendInvite(roomId, userId, {
        type,
        action: val
      })
      return
    }
  }

  async updateUserMediaState(userId: string, type: MeetingMessageType, active: boolean, apply: boolean = false) {
    const roomId = this.state.confState.roomId
    const muteAllAudio = this.state.confState.muteAllAudio
    const isMe = userId === this.state.me.userId
    const isHost = this.state.me.role === 1

    if (apply) {
      if (isMe && isHost) {
        await confApi.sendInvite(roomId, userId, {
          type,
          action: +active
        })
        return
      }
      if (isMe && !isHost) {
        await confApi.sendApply(roomId, userId, {
          type,
          action: +active
        })
        return
      }
    }

    const transformKey = {
      [MeetingMessageType.audio]: 'enableAudio',
      [MeetingMessageType.video]: 'enableVideo',
      [MeetingMessageType.board]: 'grantBoard',
      [MeetingMessageType.chat]: 'enableChat'
    }
    const key = transformKey[type]
    await confApi.updateUserMediaState(roomId, userId, {
      [`${key}`]: +active
    })

    const me = this.state.me

    const hosts = this.state.users.hosts
    const audiences = this.state.users.audiences

    if (me.userId === userId) {
      this.state = {
        ...this.state,
        me: {
          ...this.state.me,
          [`${type}`]: +active,
        },
        // users: {
        //   ...this.state.users,
        // }
      }
      this.commit(this.state)
      return
    } else {
      const host = hosts.find((user: AgoraUser) => user.userId === userId)
      if (host){
        this.state = {
          ...this.state,
          users: {
            ...this.state.users,
            hosts: hosts.update(`${host.uid}`, (user: AgoraUser) => ({...user, [`${type}`]: +active}))
          }
        }
        this.commit(this.state)
        return
      }

      const audience = hosts.find((user: AgoraUser) => user.userId === userId)
      if (audience){
        this.state = {
          ...this.state,
          users: {
            ...this.state.users,
            audiences: audiences.update(`${audience.uid}`, (user: AgoraUser) => ({...audience, [`${type}`]: +active}))
          }
        }
        this.commit(this.state)
        return
      }

    }
  }

  async updateLocalChatState(active: boolean) {
    const myUserId = this.state.me.userId
    await this.updateUserMediaState(myUserId, MeetingMessageType.chat, active)
  }

  async updateLocalBoardState(active: boolean) {
    const myUserId = this.state.me.userId
    await this.updateUserMediaState(myUserId, MeetingMessageType.board, active)
  }

  async updateLocalVideoState(active: boolean) {
    const myUserId = this.state.me.userId
    await this.updateUserMediaState(myUserId, MeetingMessageType.video, active)
  }

  async updateLocalAudioState(active: boolean) {
    const myUserId = this.state.me.userId
    await this.updateUserMediaState(myUserId, MeetingMessageType.audio, active)
  }

  async updateScreenShareState() {

    const nextState = this.state.confState.shareBoard ? 0 : 1

    await confApi.updateShareScreen(this.state.confState.roomId, this.state.me.userId, nextState)

    this.state = {
      ...this.state,
      confState: {
        ...this.state.confState,
        shareBoard: +nextState
      }
    }
    this.commit(this.state)
  }

  async forceMuteAllAudio(force: boolean) {
    const val = force === true ? 2 : 1
    await confApi.updateGlobalRoomState(this.state.confState.roomId, {
      muteAllAudio: val
    })

    this.state = {
      ...this.state,
      confState: {
        ...this.state.confState,
        muteAllAudio: 2
      },
      users: {
        ...this.state.users,
        audiences: this.state.users.audiences.map((user: AgoraUser) => ({...user, audio: 0}))
      }
    }
    this.commit(this.state)
  }

  async sendUnmuteAllAudio() {

    await confApi.updateGlobalRoomState(this.state.confState.roomId, {
      muteAllAudio: 0
    })

    this.state = {
      ...this.state,
      confState: {
        ...this.state.confState,
        muteAllAudio: 0
      },
    }
    this.commit(this.state)
  }

  findUserBy(userId: string, collect: Map<string, AgoraUser>) {
    const user = collect.find((user: AgoraUser) => user.userId === userId)
    return user
  }

  updateUserSnapshot(collect: Map<string, AgoraUser>, user: Partial<AgoraUser>, operate: 'remove' | 'upsert') {
    if (operate === 'remove') {
      return collect.delete(`${user.uid}`)
    }

    return collect.set(`${user.uid}`, {
      ...(user as AgoraUser)
    })
  }
  
  updateRole(newHosts: AgoraUser[], newAudiences: AgoraUser[], users: any) {
    // const users = collect ? collect : users 

    let {
      hosts: prevHosts,
      audiences: prevAudiences,
    } = users

    const hostIds = newHosts
    .map((res: AgoraUser) => res.userId)

    const audienceIds = newAudiences
    .map((res: AgoraUser) => res.userId)

    // upsert new audiences
    prevAudiences = newAudiences.reduce((acc: Map<string, AgoraUser>, it: AgoraUser) => {
      acc = acc.set(`${it.uid}`, {
        ...acc.get(`${it.uid}`),
        ...it
      })
      return acc
    }, prevAudiences)

    // upsert new hosts
    prevHosts = newHosts.reduce((acc: Map<string, AgoraUser>, it: AgoraUser) => {
      acc = acc.set(`${it.uid}`, {
        ...acc.get(`${it.uid}`),
        ...it
      })
      return acc
    }, prevHosts)

    // remove prev hosts from audiences
    prevAudiences = prevAudiences
    .filterNot(
      (it: AgoraUser) => 
      hostIds.indexOf(it.userId) !== -1
    )
      
    // remove prev hosts from newAudiences
    prevHosts = prevHosts
    .filterNot(
      (it: AgoraUser) => 
      audienceIds.indexOf(it.userId) !== -1)

    return {
      hosts: prevHosts,
      audiences: prevAudiences,
    }
  }

  removeUsers(userIds: string[]) {
    const snapShotReduce = this.state.users
    return userIds.reduce((acc: any, userId: string) => {
      acc = this.removeUserBy(userId, acc)
      return acc
    }, snapShotReduce)
  }

  upsertUsers(users: AgoraUser[], prevUsersSnapShot: any) {
    const nextUsersSnapShotState = prevUsersSnapShot

    return users.reduce((acc: any, user: AgoraUser) => {
      const upsertSnapShot = this.upsertUser(user, acc)
      return upsertSnapShot
    }, nextUsersSnapShotState)
  }

  removeUserBy(userId: string, users: any) {
    // const users = this.state.users

    const {
      hosts,
      audiences,
      shareBoardUsers,
      shareScreenUsers
    } = users

    const host = this.findUserBy(userId, hosts)
    const audience = this.findUserBy(userId, audiences)
    const shareBoardUser = this.findUserBy(userId, shareBoardUsers)
    const shareScreenUser = this.findUserBy(userId, shareScreenUsers)

    let newHosts: Map<string, AgoraUser> = hosts

    if (host) {
      newHosts = this.updateUserSnapshot(hosts, host, 'remove')
    }

    let newAudiences: Map<string, AgoraUser> = audiences

    if (audience) {
      newAudiences = this.updateUserSnapshot(audiences, audience, 'remove')
    }
    
    let newShareBoardUsers: Map<string, AgoraUser> = shareBoardUsers

    if (shareBoardUser) {
      newShareBoardUsers = this.updateUserSnapshot(shareBoardUsers, shareBoardUser, 'remove')
    }

    let newShareScreenUsers: Map<string, AgoraUser> = shareScreenUsers

    if (shareScreenUser) {
      newShareScreenUsers = this.updateUserSnapshot(hosts, shareScreenUser, 'remove')
    }

    const newUsersStateSnapshot = {
      hosts: newHosts,
      audiences: newAudiences,
      shareBoardUsers: newShareBoardUsers,
      shareScreenUsers: newShareScreenUsers,
    }
    return newUsersStateSnapshot
  }

  upsertUser(user: any, users: any) {
    const userId = user.userId

    const {
      hosts,
      audiences,
      shareBoardUsers,
      shareScreenUsers
    } = users

    const host = this.findUserBy(userId, hosts)
    const audience = this.findUserBy(userId, audiences)
    const shareBoardUser = this.findUserBy(userId, shareBoardUsers)
    const shareScreenUser = this.findUserBy(userId, shareScreenUsers)

    let newHosts: Map<string, AgoraUser> = hosts

    if (user.role === 1) {
      const record = {
        ...host,
        ...user,
      }
      newHosts = this.updateUserSnapshot(hosts, record, 'upsert')
    }

    let newAudiences: Map<string, AgoraUser> = audiences

    if (user.role === 2) {
      const record = {
        ...audience,
        ...user,
      }
      newAudiences = this.updateUserSnapshot(audiences, record, 'upsert')
    }

    let newShareBoardUsers: Map<string, AgoraUser> = shareBoardUsers

    if (shareBoardUser) {
      const record = {
        ...shareBoardUser,
        ...user,
        chat: user.chat,
        video: user.video,
        audio: user.audio
      }
      newShareBoardUsers = this.updateUserSnapshot(shareBoardUsers, record, 'upsert')
    }

    let newShareScreenUsers: Map<string, AgoraUser> = shareScreenUsers

    if (shareScreenUser) {
      const record = {
        ...shareScreenUser,
        ...user,
        chat: user.chat,
        video: user.video,
        audio: user.audio
      }
      newShareScreenUsers = this.updateUserSnapshot(hosts, record, 'upsert')
    }

    const newUsersState = {
      hosts: newHosts,
      audiences: newAudiences,
      shareBoardUsers: newShareBoardUsers,
      shareScreenUsers: newShareScreenUsers,
    }

    return newUsersState
  }

  async kickUserBy(userId: string) {
    const roomId = this.state.confState.roomId
    await confApi.kickUserBy(userId, roomId)

    const newUsersState = this.removeUsers([userId])

    this.state = {
      ...this.state,
      users: {
        ...this.state.users,
        ...newUsersState
      }
    }
    this.commit(this.state)
  }

  async setNewHostUserBy(userId: string) {
    const audiences = this.state.users.audiences
    const roomId = this.state.confState.roomId

    const audience = audiences.find((user: any) => user.userId === userId)

    if (!audience) {
      console.warn("audience not found", userId)
      return;
    }

    await confApi.setNewHostUserBy(roomId, userId)

    let userSnapShot = this.removeUsers([this.state.me.userId])

    const newUsersState = this.upsertUsers([audience], userSnapShot)

    this.state = {
      ...this.state,
      me: {
        ...this.state.me,
        role: 2,
      },
      users: {
        ...this.state.users,
        ...newUsersState
      }
    }

    this.commit(this.state)
  }

  async cancelBoard(userId: string) {
    const roomId = this.state.confState.roomId
    const ownerUserId = this.state.confState.createBoardUserId
    const myUserId = this.state.me.userId

    if (userId === myUserId || ownerUserId === myUserId) {
      try {
        await confApi.updateShareBoard(roomId, userId, 0)
      } catch(err) {
        throw err
      } finally {
        if (userId === myUserId) {
          globalStore.showToast({
            type: 'cancelBoard',
            message: t(`meeting.cancel_board`)
          })
        }
      }
    }
  }

  async applyBoard() {
    const roomId = this.state.confState.roomId
    const ownerId = this.state.confState.createBoardUserId
    try {
      await confApi.sendApply(roomId, ownerId, {
        type: MeetingMessageType.board,
        action: 1
      })
      globalStore.showToast({
        type: 'roomNotice',
        message: t('meeting.apply_board')
      })
    } catch(err) {
      throw err
    }
    // await await confApi.updateShareBoard(roomId, userId, 1)
  }

  async applyAudio(userId: string, type: MeetingMessageType) {
    const roomId = this.state.confState.roomId
    const muteAllAudio = this.state.confState.muteAllAudio

    const isHost = this.state.me.role === 1

    const isMe = this.state.me.userId === userId

    if (muteAllAudio === 2
      && isMe && !isHost
    ) {
      const hosts = this.state.users.hosts
      if (hosts.count() === 0) return console.warn("host is empty")
      const host: AgoraUser = this.state.users.hosts.toArray().map((res: any[]) => res[1])[0]
      if (host.userId) {
        await confApi.sendApply(roomId, host.userId, {
          type,
          action: 1
        })
        return
      }
    }
  }

  async grantAudienceBoard(userId: string, state: number) {
    const roomId = this.state.confState.roomId
    const audiences = this.state.users.audiences

    const audience = audiences.find((user: any) => user.userId === userId)

    if (!audience) {
      console.warn("audience not found", userId)
      return;
    }

    await confApi.setGrantBoard(roomId, userId, state)

    const me = this.state.me

    const isMe = me.userId === userId

    if (isMe) {
      this.state = {
        ...this.state,
        me: {
          ...me,
          grantBoard: state,
        },
        users: {
          ...this.state.users,
          audiences: audiences.set(`${audience.uid}`, {
            ...audience,
            grantBoard: state
          })
        }
      }
    } else {
      this.state = {
        ...this.state,
        users: {
          ...this.state.users,
          audiences: audiences.set(`${audience.uid}`, {
            ...audience,
            grantBoard: state
          })
        }
      }
    }
    this.commit(this.state)
  }

  async setGrantBoard(userId: string, val?: number) {
    const roomId = this.state.confState.roomId
    const audiences = this.state.users.audiences

    const audience = audiences.find((user: any) => user.userId === userId)

    if (!audience) {
      console.warn("audience not found", userId)
      return;
    }

    let state = audience.grantBoard ? 0 : 1

    if (val !== undefined) {
      state = val
    }

    await confApi.setGrantBoard(roomId, userId, state)

    const me = this.state.me

    const isMe = me.userId === userId

    if (isMe) {
      this.state = {
        ...this.state,
        me: {
          ...me,
          grantBoard: state,
        },
        users: {
          ...this.state.users,
          audiences: audiences.set(`${audience.uid}`, {
            ...audience,
            grantBoard: state
          })
        }
      }
    } else {
      this.state = {
        ...this.state,
        users: {
          ...this.state.users,
          audiences: audiences.set(`${audience.uid}`, {
            ...audience,
            grantBoard: state
          })
        }
      }
    }
    this.commit(this.state)
  }

  switchStream(largeUid: number) {
    const webClient = this.rtcClient as AgoraWebClient
    const streams = this.state.rtc.remoteStreams
    if (webClient) {
      const stream = streams.get(`${largeUid}`)
      const otherStreams = streams.filterNot((stream: AgoraStream) => stream.streamID === largeUid && !stream.stream)
      otherStreams.forEach((stream: AgoraStream) => {
        webClient.setRemoteVideoStreamType(stream.stream, 1)
      })
      if (stream) {
        webClient.setRemoteVideoStreamType(stream.stream, 0)
      }
    }
  }

  changeSessionInfo (sessionInfo: Partial<SessionInfo>) {
    this.state = {
      ...this.state,
      sessionInfo: {
        ...this.state.sessionInfo,
        ...sessionInfo
      }
    }
    this.commit(this.state)
  }

  setCameraIdx(idx: number) {
    this.state = {
      ...this.state,
      mediaDevice: {
        ...this.state.mediaDevice,
        cameraIdx: idx,
      }
    }
    this.commit(this.state)
  }

  setMicrophoneIdx(idx: number) {
    this.state = {
      ...this.state,
      mediaDevice: {
        ...this.state.mediaDevice,
        microphoneIdx: idx,
      }
    }
    this.commit(this.state)
  }

  removeInviteDialog() {
    this.state = {
      ...this.state,
      inviteDialog: false,
      inviteDialogBottom: false
    }
    this.commit(this.state)
  }

  toggleInviteDialog () {
    this.state = {
      ...this.state,
      inviteDialog: !this.state.inviteDialog,
      inviteDialogBottom: false
    }
    this.commit(this.state)
  }

  toggleInviteFromBottom () {
    this.state = {
      ...this.state,
      inviteDialogBottom: !this.state.inviteDialogBottom,
      inviteDialog: false,
    }
    this.commit(this.state)
  }

  setMaximum(val: boolean) {
    this.state = {
      ...this.state,
      maximum: val
    }
    this.commit(this.state)
  }

  toggleMaximum() {
    this.state = {
      ...this.state,
      maximum: !this.state.maximum
    }
    this.commit(this.state)
  }
}

export const roomStore = new RoomStore();

// TODO: Please remove it before release in production
// 备注：请在正式发布时删除操作的window属性
//@ts-ignore
window.roomStore = roomStore;