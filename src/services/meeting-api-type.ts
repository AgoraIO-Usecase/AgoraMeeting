import { AgoraUser, Me } from '@/stores/room';
import {Map} from 'immutable';

export interface RoomInfo {
  me: Me
  roomInfo: {
    createBoardUserId: string
    shareScreenUsers: Map<string, AgoraUser>
    shareBoardUsers: Map<string, AgoraUser>
    hosts: Map<string, AgoraUser>
    audiences: Map<string, AgoraUser>
    appID: string
    onlineUsers: number
    roomName: string
    roomId: string
    roomUuid: string
    channelName: string
    muteAllChat: number
    muteAllAudio: number
    startTime: number
    boardId: string
    boardToken: string
    shareBoard: number
    shareScreen: number
  }
}