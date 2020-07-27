import { ConfState, AgoraUser, RoomUsers } from '@/stores/room';
import { RoomMessage } from '@/utils/agora-rtm-client';
import OSS from 'ali-oss';
import {get} from 'lodash';

export const transformMediaState = (
  me: AgoraUser,
  user: AgoraUser,
  users: Exclude<RoomUsers, 'onlineUsers'>,
  confState: Pick<ConfState, keyof ConfState>,
  ) => {
  const myUserId = me.userId
  const myRole = me.role

  const {
    createBoardUserId,
    muteAllAudio
  } = confState

  const {
    shareBoardUsers,
    shareScreenUsers
  } = users

  const amHost = myRole === 1

  return {
    isHost: amHost ? 1 : 0,
    isMe: user.userId === myUserId ? 1 : 0,
    isBoardOwner: user.userId === createBoardUserId ? 1 : 0,
    grantBoard: shareBoardUsers.get(`${user.userId}`) || user.grantBoard ? 1 : 0,
    grantScreen: shareScreenUsers.get(`${user.userId}`) || user.grantScreen ? 1 : 0,
    createBoardUserId,
    muteAllAudio
  }
}

export function resolveMessage(peerId: string, { cmd, text }: { cmd: number, text?: string }) {
  let type = '';
  switch (cmd) {
    case RoomMessage.acceptCoVideo:
      type = 'accept co-video'
      break;
    case RoomMessage.rejectCoVideo:
      type = 'reject co-video'
      break;
    case RoomMessage.cancelCoVideo:
      type = 'cancel co-video'
      break;
    case RoomMessage.applyCoVideo:
      type = 'apply co-video'
      break;
    case RoomMessage.muteVideo:
      type = 'mute video'
      break;
    case RoomMessage.muteAudio:
      type = 'mute audio'
      break;
    case RoomMessage.unmuteAudio:
      type = 'unmute audio'
      break;
    case RoomMessage.unmuteVideo:
      type = 'unmute video'
      break;
    default:
      return console.warn(`[RoomMessage] unknown type, from peerId: ${peerId}`);
  }
  console.log(`[RoomMessage] [${type}] from peerId: ${peerId}`)
}

export interface UserAttrs {
  uid: string
  userName: string
  role: string
  audio: number
  video: number
  chat: number
  whiteboard_uid?: string
  link_uid?: number
  shared_uid?: number
  mute_chat?: number
  class_state?: number
}

export function resolveMediaState(body: any) {
  const cmd: number = body.cmd;
  const mediaState = {
    key: 'unknown',
    val: -1,
  }
  switch (cmd) {
    case RoomMessage.muteVideo:
      mediaState.key = 'video'
      mediaState.val = 0
      break
    case RoomMessage.unmuteVideo:
      mediaState.key = 'video'
      mediaState.val = 1
      break
    case RoomMessage.muteAudio:
      mediaState.key = 'audio'
      mediaState.val = 0
      break
    case RoomMessage.unmuteAudio:
      mediaState.key = 'audio'
      mediaState.val = 1
      break
    case RoomMessage.muteAllChat:
      mediaState.key = 'chat'
      mediaState.val = 0
      break
    case RoomMessage.unmuteChat:
      mediaState.key = 'chat'
      mediaState.val = 1
      break
    default:
      console.warn('[rtm-message] unknown message protocol');
  }
  return mediaState;
}

export function genUid(): string {
  const id = +Date.now() % 1000000;
  return id.toString();
}

export function jsonParse(json: string) {
  try {
    return JSON.parse(json);
  } catch (err) {
    return {};
  }
}

export function resolvePeerMessage(text: string) {
  const body = jsonParse(text);
  return body;
}

export const resolveFileInfo = (file: any) => {
  const fileName = encodeURI(file.name);
  const fileType = fileName.substring(fileName.length, fileName.lastIndexOf('.'));
  return {
    fileName,
    fileType
  }
}

const level = [
  'unknown',
  'excellent',
  'good',
  'poor',
  'bad',
  'very bad',
  'down'
];

export function NetworkQualityEvaluation(evt: { downlinkNetworkQuality: number, uplinkNetworkQuality: number }) {
  let defaultQuality = 'unknown';
  const val = Math.max(evt.downlinkNetworkQuality, evt.uplinkNetworkQuality);
  return level[val] ? level[val] : defaultQuality;
}

export function btoa(input: any) {
  let keyStr =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  let output = '';
  let chr1, chr2, chr3, enc1, enc2, enc3, enc4;
  let i = 0;

  while (i < input.length) {
    chr1 = input[i++];
    chr2 = i < input.length ? input[i++] : Number.NaN; // Not sure if the index
    chr3 = i < input.length ? input[i++] : Number.NaN; // checks are needed here

    enc1 = chr1 >> 2;
    enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
    enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
    enc4 = chr3 & 63;

    if (isNaN(chr2)) {
      enc3 = enc4 = 64;
    } else if (isNaN(chr3)) {
      enc4 = 64;
    }
    output +=
      keyStr.charAt(enc1) +
      keyStr.charAt(enc2) +
      keyStr.charAt(enc3) +
      keyStr.charAt(enc4);
  }
  return output;
}