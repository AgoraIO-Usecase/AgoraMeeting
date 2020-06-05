import { AgoraMediaStream, AgoraStream } from '@/utils/types';
import { useMemo } from 'react';
import { RoomState, AgoraUser, roomStore } from '@/stores/room';
import { List, Map } from 'immutable';
import { transformMediaState } from '@/utils/helper';

type StreamValue = {
  teacher: any
  students: any[]
  sharedStream: any
  currentHost: any
  onPlayerClick: (type: string, streamID: number, uid: string) => Promise<any>
}

export const useStreams = ({
  me,
  confState,
  rtc,
  users,
}: RoomState) => {

  const largeStream: AgoraMediaStream | null = useMemo(() => {
    // when room has board owner
    if (confState.createBoardUserId !== '0') return null

    // share screen
    if (confState.shareScreen) {
      let member = null

      let stream = null

      let sharedUser = users.shareScreenUsers.first() as AgoraUser

      if (!sharedUser) {
        return null
      } else {
        member = sharedUser
      }

      const remoteStream = member ? rtc.remoteStreams.get(`${member.screenId}`) : ''

      if (remoteStream) {
        stream = remoteStream.stream
      }

      if (member) {
        const mediaState = transformMediaState(me, member, users, confState)

        const screenStream: AgoraMediaStream = {
          uid: +member.uid,
          userId: member.userId,
          userName: member.userName,
          video: 1,
          audio: 1,
          chat: member.chat,
          // grantBoard: member.grantBoard,
          // grantScreen: member.grantScreen,
          stream: stream,
          role: member.role,
          local: member.userId === me.userId,
          screen: true,
          // muteAllAudio: confState.muteAllAudio,
          // shareBoard: confState.createBoardUserId === member.userId ? 1 : 0,
          ...mediaState
        }
        return screenStream
      }
    }

    const host = users.hosts.first() as AgoraUser

    const member = host ? host : me

    if (member) {

      let stream = null

      if (member.userId === me.userId)  {
        stream = rtc.localStream ? rtc.localStream.stream : null
      } else {
        const remoteStream = rtc.remoteStreams.get(`${member.uid}`)
        stream = remoteStream ? remoteStream.stream : null
      }

      const mediaState = transformMediaState(me, member, users, confState)

      const screenStream: AgoraMediaStream = {
        uid: +member.uid,
        userId: member.userId,
        userName: member.userName,
        video: member.video,
        audio: member.audio,
        chat: member.chat,
        // grantBoard: member.grantBoard,
        // grantScreen: member.grantScreen,
        stream: stream,
        role: member.role,
        local: member.userId === me.userId,
        screen: false,
        // muteAllAudio: confState.muteAllAudio,
        // shareBoard: confState.createBoardUserId === member.userId ? 1 : 0,
        ...mediaState
      }
      return screenStream
    }
    return null
  }, [
    me,
    rtc.localStream,
    // rtc.largeScreenUserId,
    rtc.remoteStreams, 
    users.audiences,
    users.hosts,
    users.shareBoardUsers,
    users.shareScreenUsers,
    confState.muteAllAudio,
    confState.createBoardUserId,
    confState.shareBoard,
    confState.shareScreen,
  ])

  const otherStreams: List<AgoraMediaStream> = useMemo(() => {
    const hash: {[userId: string]: any}={}
    const _members = [me]
    .concat(users.hosts.toArray().map((res: any) => res[1]))
    .concat(users.audiences.toArray().map((res: any) => res[1]))
    .reduce((vector: any, next: any) => {
      if (!hash[next.userId]) {
        const mediaState = transformMediaState(
          me,
          next,
          users,
          confState
        )
        const rawNext = {
          ...next,
          ...mediaState
        }
        vector.push(rawNext)
        hash[next.userId] = true
      }
      return vector;
    }, [])

    const largeScreenUid = largeStream ? largeStream.uid : -1

    let sharedUser = users.shareScreenUsers.first() as AgoraUser

    console.log(`largeScreenUid: ${largeScreenUid}, sharedUser: ${sharedUser && sharedUser.screenId}`)
    console.log(users.shareScreenUsers.first())

    const members = _members
    .filter((member: any) => {
      if (largeScreenUid !== -1) {
        // exclude large screen uid
        if (+member.uid !== largeScreenUid) {
          return true
        } else {
          if (sharedUser && +sharedUser.uid === largeScreenUid) {
            return true
          }
          return false
        }
      }
      return true
    })

    console.log("members", members.length, JSON.stringify(_members))

    return members
      .reduce((acc: List<AgoraMediaStream>, member: any) => {
      let stream: any = null

      let local = false

      if (rtc.localStream && +rtc.localStream.streamID === +member.uid) {
        stream = rtc.localStream.stream
        local = true
      }

      // if (rtc.localSharedStream && rtc.localSharedStream.streamID && +rtc.localSharedStream.streamID === +member.uid) {
      //   stream = rtc.localSharedStream.stream
      // }

      const remoteStream = rtc.remoteStreams.get(`${+member.uid}`)
      if (remoteStream && remoteStream.streamID && +remoteStream.streamID === +member.uid) {
        stream = remoteStream.stream
        local = false
      }

      if (!member.uid) {
        return acc
      }

      return acc.push({
        uid: +member.uid,
        userId: member.userId,
        userName: member.userName,
        video: member.video,
        audio: member.audio,
        chat: member.chat,
        grantBoard: member.grantBoard,
        grantScreen: member.grantScreen,
        stream: stream,
        role: member.role,
        local: local,
        screen: false,
        muteAllAudio: confState.muteAllAudio,
        shareBoard: confState.shareBoard ? 1 : 0,
        isBoardOwner: +member.isBoardOwner,
        createBoardUserId: member.createBoardUserId,
        isHost: member.isHost,
        isMe: member.isMe,
      })
    }, List<AgoraMediaStream>())
  }, [
    largeStream,
    me,
    me.grantBoard,
    rtc.localStream,
    // rtc.localSharedStream,
    // rtc.largeScreenUserId,
    rtc.remoteStreams,
    users.audiences,
    users.hosts,
    users.shareBoardUsers,
    users.shareScreenUsers,
    confState.muteAllAudio,
    confState.createBoardUserId,
    confState.shareBoard,
    confState.shareScreen,
  ])


  useMemo(() => {
    roomStore.switchStream(largeStream && largeStream.stream ? +largeStream.uid : -1)
  }, [largeStream])

  return {
    largeStream,
    otherStreams,
  }
}