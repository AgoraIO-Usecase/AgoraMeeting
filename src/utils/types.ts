export interface ChatMessage {
  userName: string
  text: string
  link?: string
  ts: number
  id: string
  sender: boolean
}
export enum ClassState {
  CLOSED = 0,
  STARTED = 1
}

export interface AgoraMediaStream {
  uid: number
  userId: string
  userName: string
  video: number
  audio: number
  chat: number
  grantBoard: number
  grantScreen: number
  stream: any
  role?: number
  local?: boolean
  screen?: boolean
  muteAllAudio: number
  shareBoard?: number
  isHost: number
  isMe: number
  // muteAllChat: number
  createBoardUserId: string
  isBoardOwner: number
}

export class AgoraStream {
  constructor(
    public readonly stream: any = stream,
    public readonly streamID: number = streamID,
    public readonly local: boolean = local,
  ) {
  }
}