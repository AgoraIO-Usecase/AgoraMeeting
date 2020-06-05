import { MeetingMessageType } from '@/utils/agora-rtm-client';
import { BUILD_VERSION, t } from '@/i18n';
import { AgoraFetch } from '@/utils/fetch';
import { ConfState, AgoraUser, Me } from '@/stores/room';
import {Map} from 'immutable'
import {get} from 'lodash'
import { getIntlError, setIntlError } from '@/services/intl-error-helper';
import { globalStore } from '@/stores/global';
import { historyStore } from '@/stores/history';
import OSS from 'ali-oss';
import axios from 'axios';
 /* eslint-disable */ 
import Log from '@/utils/LogUploader';
import { APP_ID } from '@/utils/config';
import { RoomInfo } from '@/services/meeting-api-type';

const whiteboardGenerateTokenApiEndpoint = process.env.REACT_APP_YOUR_BACKEND_WHITEBOARD_API as string;

export interface UserAttrsParams {
  userId: string
  enableChat: number
  enableVideo: number
  enableAudio: number
  grantBoard: number
  // coVideo?: number
}

const PREFIX: string = process.env.REACT_APP_AGORA_EDU_ENDPOINT_PREFIX as string;
const AUTHORIZATION: string = process.env.REACT_APP_AGORA_RESTFULL_TOKEN as string;

const AgoraFetchJson = async ({url, method, data, token, full_url}:{url?: string, method: string, data?: any, token?: string, full_url?: string}) => {  
  const opts: any = {
    method,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Basic ${AUTHORIZATION?.replace(/basic\s+|basic/i, '')}`
    }
  }

  if (token) {
    opts.headers['token'] = token;
  }
  if (data) {
    opts.body = JSON.stringify(data);
  }

  let resp = undefined;
  if (full_url) {
    resp = await AgoraFetch(`${full_url}`, opts);
  } else {
    resp = await AgoraFetch(`${PREFIX}${url}`, opts);
  }
  const {code, msg, data: responseData} = resp

  if (code !== 0 && code !== 408) {
    const error = getIntlError(`${code}`)
    const isErrorCode = `${error}` === `${code}`
    globalStore.showToast({
      type: 'confApiError',
      message: isErrorCode ? `${msg}` : error
    })
    if (code === 401 || code === 1101012) {
      // historyStore.state.history.goBack()
      historyStore.state.history.push('/')
      return
    }
    throw {api_error: error, isErrorCode}
  }

  return responseData
}

export interface EntryParams {
  userName: string
  roomName: string
  roomUuid: string
  userUuid: string
  password: string
  enableVideo: number
  enableAudio: number
  // type: number
  // role: number
}

export type RoomParams = Partial<{
  muteAllChat: boolean
  confState: number
  [key: string]: any
}>

type FileParams = {
  file: any,
  key: string,
  host: string,
  policy: any,
  signature: any,
  callback: any,
  accessid: string
}

const uploadLogToOSS = async ({
  file,
  key,
  host,
  policy,
  signature,
  callback,
  accessid
}: FileParams) => {
  const formData = new FormData()
  formData.append('name', 'test.log')
  formData.append('key', key)
  formData.append('file', file)
  formData.append('policy',policy)
  formData.append('OSSAccessKeyId',accessid)
  formData.append('success_action_status','200')
  formData.append('callback',callback)
  formData.append('signature',encodeURIComponent(signature).replace(/%20/g,'+'))
  return await axios.post(host, formData, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded'}
  })
}

export class AgoraConfApi {

  appID: string = APP_ID;
  roomId: string = '';
  nextId: number = 0;
  public _userToken: string = '';

  public get userToken(): string {
    const userToken = window.sessionStorage.getItem('edu-userToken') as string || '';
    return userToken;
  }

  public set userToken(token: string) {
    window.sessionStorage.setItem('edu-userToken', token)
  }
  
  recordId: string = '';

  // fetch stsToken
  // 获取 stsToken
  async fetchStsToken(roomId: string, fileExt: string) {
    // NOTE: demo feedback only
    const appCode = 'conf-demo'
    const _roomId = roomId ? roomId : 0;
    let data = await AgoraFetchJson({
      url: `/v1/log/params?appCode=${appCode}&osType=${3}&terminalType=${3}&appVersion=${BUILD_VERSION}&roomId=${_roomId}&fileExt=${fileExt}&appId=${this.appID}`,
      method: 'GET',
    })

    return {
      bucketName: data.bucketName as string,
      callbackBody: data.callbackBody as string,
      callbackContentType: data.callbackContentType as string,
      accessKeyId: data.accessKeyId as string,
      accessKeySecret: data.accessKeySecret as string,
      securityToken: data.securityToken as string,
      ossKey: data.ossKey as string,
    }
  }

  async uploadToOss(roomId: string, file: any, ext: string) {
    let {
      bucketName,
      callbackBody,
      callbackContentType,
      accessKeyId,
      accessKeySecret,
      securityToken,
      ossKey
    } = await this.fetchStsToken(roomId, ext);
    const ossParams = {
      bucketName,
      callbackBody,
      callbackContentType,
      accessKeyId,
      accessKeySecret,
      securityToken,
    }
    const ossClient = new OSS({
      accessKeyId: ossParams.accessKeyId,
      accessKeySecret: ossParams.accessKeySecret,
      stsToken: ossParams.securityToken,
      bucket: ossParams.bucketName,
      secure: true,
      // TODO: 请传递你自己的oss endpoint
      // TODO: Please use your own oss endpoint
      endpoint: 'oss-accelerate.aliyuncs.com',
    })

    const url = `${PREFIX}/v1/log/sts/callback`
    try {
      return await ossClient.put(ossKey, file, {
        callback: {
          url: `${PREFIX}/v1/log/sts/callback`,
          body: callbackBody,
          contentType: callbackContentType,
        }
      });
    } catch(err) {
      globalStore.showToast({
        type: 'oss',
        message: t('toast.upload_log_failure', {reason: err.name})
      })
      throw err
    }
  }

  async uploadZipLogFile(
    roomId: string,
    file: any
  ) {
    const res = await this.uploadToOss(roomId, file, 'zip')
    return res;
  }

  // upload log
  async uploadLogFile(
    roomId: string,
    file: any
  ) {
    const res = await this.uploadToOss(roomId, file, 'log')
    return res;
  }

  // fetch i18n
  static async fetchI18n() {
    let data = await AgoraFetchJson({
      url: `/v1/multi/language`,
      method: 'GET',
    });

    setIntlError(data || {})
  }

  // app config
  // 配置入口
  // async config() {
  //   let data = await AgoraFetchJson({
  //     url: `/v1/config?platform=0&device=0&version=5.2.0`,
  //     method: 'GET',
  //   });

  //   if (data['multiLanguage']) {
  //     setIntlError(data['multiLanguage'])
  //   }

  //   return {
  //     appId: data.appId,
  //     room: data.room,
  //   }
  // }

  // room entry
  // 房间入口
  async entry(params: EntryParams) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/entry`,
      method: 'POST',
      data: params,
    });

    console.log("data", data)
    
    this.roomId = data.roomId;
    this.userToken = data.userToken;
    return {
      data
    }
  }

  // refresh token
  // 刷新token 
  async refreshToken(roomId: string) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/token/refresh`,
      method: 'POST',
      token: this.userToken,
    });
    return {
      rtcToken: data.rtcToken,
      rtmToken: data.rtmToken,
      screenToken: data.screenToken
    }
  }

  // update confState
  // 更新课程状态
  async updateConf(params: Partial<RoomParams>) {
    const {room} = params
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${this.roomId}`,
      method: 'POST',
      data: room,
      token: this.userToken,
    });
    return {
      data,
    }
  }

  // updateRoomUser
  // 更新用户状态，老师可更新房间内所有人，学生只能更新自己
  async updateRoomUser(user: Partial<UserAttrsParams>) {
    const {userId, ...userAttrs} = user
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${this.roomId}/user/${userId}`,
      method: 'POST',
      data: userAttrs,
      token: this.userToken,
    });
    return {
      data,
    }
  }

  // start recording
  // 开始录制
  async startRecording() {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${this.roomId}/record/start`,
      method: 'POST',
      data: {},
      token: this.userToken,
    });
    this.recordId = data.recordId
    return {
      data
    }
  }

  // stop recording
  // 结束录制
  async stopRecording(recordId: string) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${this.roomId}/record/${recordId}/stop`,
      method: 'POST',
      token: this.userToken,
    })
    return {
      data
    }
  }

  // get recording list
  // 获取录制列表
  async getRecordingList () {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${this.roomId}/records`,
      method: 'GET',
      token: this.userToken,
    })
    return {
      data
    }
  }

  // get whiteboard token
  async getWhiteboardBy(roomId: string): Promise<any> {
    let boardData = await AgoraFetchJson({
      full_url: whiteboardGenerateTokenApiEndpoint.replace('%app_id%', this.appID).replace('%room_id%', roomId),
      method: 'GET',
      token: this.userToken,
    })
    return {
      boardId: get(boardData, 'boardId', null),
      boardToken: get(boardData, 'boardToken', null),
    };
  }

  // get room info
  // 获取房间信息
  async getRoomInfoBy(roomId: string, userToken?: string): Promise<{data: any}> {
    if (userToken) {
      this.userToken = userToken
    }

    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}`,
      method: 'GET',
      token: this.userToken,
    });
    let boardData = await this.getWhiteboardBy(roomId);

    const hosts: Map<string, AgoraUser> = data.room
    .hosts
    .reduce((acc: Map<string, AgoraUser>, it: any) => {
       return acc.set(`${it.uid}`, {
          role: it.role,
          userName: it.userName,
          uid: it.uid,
          video: it.enableVideo,
          audio: it.enableAudio,
          chat: it.enableChat,
          grantBoard: it.grantBoard,
          grantScreen: it.grantScreen,
          userId: it.userId,
          screenId: it.screenId,
        });
    }, Map<string, AgoraUser>());

    const shareBoardUsers: Map<string, AgoraUser> = data.room
    .shareBoardUsers
    .reduce((acc: Map<string, AgoraUser>, it: any) => {
      return acc.set(`${it.uid}`, {
         role: it.role,
         userName: it.userName,
         uid: it.uid,
         video: it.enableVideo,
         audio: it.enableAudio,
         chat: it.enableChat,
         grantBoard: it.grantBoard,
         grantScreen: it.grantScreen,
         userId: it.userId,
         screenId: it.screenId,
       });
   }, Map<string, AgoraUser>());

   const shareScreenUsers: Map<string, AgoraUser> = data.room
   .shareScreenUsers
   .reduce((acc: Map<string, AgoraUser>, it: any) => {
      return acc.set(`${it.uid}`, {
        role: it.role,
        userName: it.userName,
        uid: it.uid,
        video: it.enableVideo,
        audio: it.enableAudio,
        chat: it.enableChat,
        grantBoard: it.grantBoard,
        grantScreen: it.grantScreen,
        userId: it.userId,
        screenId: it.screenId,
      });
  }, Map<string, AgoraUser>());

    return {
      data: {
        room: {
          ...data.room,
          boardId: boardData.boardId,
          boardToken: boardData.boardToken,
          shareBoard: data.room.shareBoard,
          shareScreen: data.room.shareScreen,
        },
        hosts,
        shareScreenUsers,
        shareBoardUsers,
        user: {
          ...data.user,
          chat: data.user.enableChat,
          video: data.user.enableVideo,
          audio: data.user.enableAudio,
        }
      }
    }
  }

  // getCourseState
  // 获取房间状态
  async getCourseState(roomId: string): Promise<Partial<ConfState>> {
    const {data} = await this.getRoomInfoBy(roomId)
    const {users, room} = data

    const result: Partial<any> = {
      roomName: room.roomName,
      roomId: room.roomId,
      // confState: room.confState,
      muteAllChat: room.muteAllChat,
      recordId: room.recordId,
      recordingTime: room.recordingTime,
      isRecording: Boolean(room.isRecording),
      boardId: room.boardId,
      boardToken: room.boardToken,
      lockBoard: room.lockBoard,
      memberCount: room.onlineUsers,
    }

    const teacher = users.find((it: any) => it.role === 1)
    if (teacher) {
      result.teacherId = teacher.uid
      result.screenId = teacher.screenId
      result.screenToken = teacher.screenToken
    }

    return result
  }

  // login 登录教室
  async Login(params: EntryParams) {
    if (!this.appID) throw `appId is empty: ${this.appID}`
    let {data: {roomId, userToken}} = await this.entry(params)

    this.nextId = 0

    const result = this.getRoomInfo(roomId, userToken)
    return result
  }

  async updateUserMediaState(
    roomId: string, myUserId: string,
    params: Partial<
      { 
        enableChat: number,
        enableAudio: number,
        enableVideo: number
      }
    >) {
    await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/user/${myUserId}`,
      method: 'POST',
      token: this.userToken,
      data: params
    })
  }

  async audienceApplyAudio(roomId: string, userId: string, state: number) {
    await this.sendApply(roomId, userId, {
      type: MeetingMessageType.audio,
      action: state ? 1 : 2
    })
  }

  async sendApply(roomId: string, userId: string, {type, action}: Partial<    { 
    type: MeetingMessageType
    action: number
  }>) {
    return await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/user/${userId}/audience/apply`,
      method: 'POST',
      token: this.userToken,
      data: {
        type,
        action
      }
    })
  }


  // NOTE: 授权白板
  async setGrantBoard(roomId: string, userId: string, state: number) {
    let data = await this.updateShareBoard(roomId, userId, state ? 1 : 0)
    return data
  }

  // // NOTE: 授权音频
  // async setGrantAudio(roomId: string, userId: string, state: number) {
  //   let data = await this.sendInvite(roomId, userId, {
  //     type: MeetingMessageType.audio,
  //     action: state ? 1 : 2
  //   })
  //   return data
  // }

  // // NOTE: 授权视频
  // async setGrantVideo(roomId: string, userId: string, state: number) {
  //   let data = await this.sendInvite(roomId, userId, {
  //     type: MeetingMessageType.video,
  //     action: state ? 1 : 2
  //   })
  //   return data
  // }

  async sendInvite(roomId: string, userId: string, {action, type}: Partial<
    { 
      type: MeetingMessageType
      action: number
    }>
  ) {
    
    return await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/user/${userId}/host/invite`,
      method: 'POST',
      token: this.userToken,
      data: {
        type,
        action
      }
    })
  }

  async getAudienceListBy(roomId: string): Promise<Map<string, AgoraUser>> {    
    const data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/user/page?role=2&nextId=${this.nextId}&count=${100}`,
      method: 'GET',
      token: this.userToken,
    })

    const audiences = data.list ? data.list : []

    const audienceMap =
    audiences
    .reduce((acc: Map<string, AgoraUser>, it: any) => {
      return acc.set(`${it.uid}`, {
         role: it.role,
         userName: it.userName,
         uid: it.uid,
         video: it.enableVideo,
         audio: it.enableAudio,
         chat: it.enableChat,
         grantBoard: it.grantBoard,
         grantScreen: it.grantScreen,
         userId: it.userId,
         screenId: it.screenId,
       });
   }, Map<string, AgoraUser>());

    this.nextId = data.nextId
    
    return audienceMap
  }

  async getRoomInfo(roomId: string, userToken: string): Promise<RoomInfo> {
    const {data: {room, user, hosts, shareScreenUsers, shareBoardUsers}} = await this.getRoomInfoBy(roomId, userToken)

    const audienceList: Map<string, AgoraUser> = await this.getAudienceListBy(roomId)

    const result: RoomInfo = {
      me: {
        ...user,
        userToken
      },
      roomInfo: {
        createBoardUserId: room.createBoardUserId,
        shareScreen: room.shareScreen,
        shareBoard: room.shareBoard,
        hosts,
        shareBoardUsers,
        shareScreenUsers,
        audiences: audienceList,
        appID: this.appID,
        roomId: room.roomId,
        onlineUsers: room.onlineUsers,
        roomName: room.roomName,
        roomUuid: room.roomUuid,
        channelName: room.channelName,
        muteAllChat: room.muteAllChat,
        muteAllAudio: room.muteAllAudio,
        startTime: room.startTime,
        boardId: room.boardId,
        boardToken: room.boardToken,
      }
    }

    return result
  }
  

  async getCourseRecordBy(recordId: string, roomId: string, token: string) {
    this.userToken = token
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/record/${recordId}`,
      method: 'GET',
      token: this.userToken,
    });

    const boardData = await this.getWhiteboardBy(roomId);
    const teacherRecord = get(data, 'recordDetails', []).find((it:any) => it.role === 1)

    const recordStatus = [
      'recording',
      'finished',
      'finished_recording_to_be_download',
      'finished_download_to_be_convert',
      'finished_convert_to_be_upload'
    ]

    const result = {
      boardId: boardData.boardId,
      boardToken: boardData.boardToken,
      startTime: data.startTime,
      endTime: data.endTime,
      url: teacherRecord?.url,
      status: data.status,
      statusText: recordStatus[data.status],
    }
    return result
  }

  async updateShareBoard(roomId: string, userId: string, state: number) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/user/${userId}/board`,
      method: 'POST',
      token: this.userToken,
      data: {
        state
      }
    })
    return data
  }

  async updateShareScreen(roomId: string, userId: string, state: number) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/user/${userId}/screen`,
      method: 'POST',
      token: this.userToken,
      data: {
        state
      }
    })
    return data
  }

  async kickUserBy(userId: string, roomId: string) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/user/${userId}/exit`,
      method: 'POST',
      token: this.userToken,
    })
    return
  }

  async exitRoom(roomId: string, userId: string) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/user/${userId}/exit`,
      method: 'POST',
      token: this.userToken,
      // data: {}
    })
    return
  }

  async updateGlobalRoomState(
    roomId: string,
    payload: Partial<{
    muteAllChat: number
    muteAllAudio: number
    state: number
    // shareBoard: number
  }>) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}`,
      method: 'POST',
      token: this.userToken,
      data: payload
    })
    return data;
  }

  async setNewHostUserBy(roomId: string, userId: string) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/user/${userId}/host`,
      method: 'POST',
      token: this.userToken,
      data: {}
    })
    return data;
  }

  // NOTE: send channel message
  // NOTE: 发送聊天消息
  async sendChannelMessage(payload: any) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${payload.roomId}/chat`,
      method: 'POST',
      token: this.userToken,
      data: {
        message: payload.message,
        type: payload.type
      }
    })

    return data;
  }

  async startScreenShare(roomId: string) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/screen`,
      method: 'POST',
      token: this.userToken,
      data: {
        state: 1
      }
    })
    return data;
  }

  async getSessionInfoBy(roomId: string) {
    let data = await AgoraFetchJson({
      url: `/apps/${this.appID}/v1/room/${roomId}/simple`,
      method: 'GET',
    })
    this.roomId = data.roomId
    return data;
  }
}

export const confApi = new AgoraConfApi();

export const fetchI18n = async () => {
  await AgoraConfApi.fetchI18n();
}
