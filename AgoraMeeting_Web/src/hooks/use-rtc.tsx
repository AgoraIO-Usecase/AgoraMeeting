import { useState, useEffect, useRef, useMemo } from 'react';
import { roomStore, Me, RoomState } from '@/stores/room';
import { confApi } from '@/services/meeting-api';
import { AgoraWebClient } from '@/utils/agora-web-client';
import { AgoraStream } from '@/utils/types';

export const useWebRTC = (roomState: RoomState) => {

  const me = roomState.me
  
  const rtc = useRef<boolean>(false);

  const canPublish = useMemo(() => {
    return me.audio | me.video
  }, [me.audio, me.video])

  const enableDual = true

  useEffect(() => {
    return () => {
      rtc.current = true
    }
  },[]);

  const publishLock = useRef<boolean>(false);

  const {rtcJoined, uid, role, mediaDevice} = useMemo(() => {
    return {
      rtcJoined: roomState.rtc.joined,
      uid: roomState.me.uid,
      role: roomState.me.role,
      mediaDevice: roomState.mediaDevice,
    }
  }, [roomState]);

  useEffect(() => {
    const rtcClient = roomStore.rtcClient;
    const webClient = rtcClient as AgoraWebClient;
    if (!webClient.published) return;
    webClient
      .unpublishLocalStream().finally(() => {
        roomStore.removeLocalStream()
      })
  }, [canPublish]);

  useEffect(() => {
    if (!rtcJoined || rtc.current) return;

    const webClient = roomStore.rtcClient as AgoraWebClient;
    const uid = +roomStore.state.me.uid as number;
    const streamSpec: any = {
      streamID: uid,
      video: true,
      audio: true,
      mirror: false,
      screen: false,
      microphoneId: roomStore.currentMicrophone,
      cameraId: roomStore.currentCamera,
    }
    console.log('canPb>>> ', canPublish, roomStore.state.me.uid);
    if (canPublish && !publishLock.current) {
      publishLock.current = true;
      Promise.all([
        webClient
        .publishLocalStream(streamSpec)
      ])
      .then((res: any[]) => {
        console.log('[agora-web] any: ', res[0], res[1]);
        console.log('[agora-web] publish local stream');
      }).catch(console.warn)
      .finally(() => {
        publishLock.current = false;
      })
    }
    // }
  }, [
    rtcJoined,
    uid,
    // role,
    mediaDevice,
    canPublish,
  ]);

  useEffect(() => {
    if (!roomState.me.uid || !roomState.confState.channelName) return;
      const webClient = roomStore.rtcClient as AgoraWebClient;
      if (webClient.joined || rtc.current) {
        return;
      }
      console.log('[agora-rtc] add event listener');
      webClient.rtc.on('onTokenPrivilegeWillExpire', (evt: any) => {
        console.log("trigger onTokenPrivilegeWillExpire")
        const roomId = roomStore.state.confState.roomId
        // you need obtain the `newToken` token from server side 
        confApi.refreshToken(roomId).then((res: any) => {
          const newToken = res.rtcToken
          webClient.rtc.renewToken(newToken);
          console.log('[agora-web] onTokenPrivilegeWillExpire', evt);
        })
      });
      webClient.rtc.on('onTokenPrivilegeDidExpire', (evt: any) => {
        console.log("trigger onTokenPrivilegeDidExpire")
        const roomId = roomStore.state.confState.roomId
        // you need obtain the `newToken` token from server side 
        confApi.refreshToken(roomId).then((res: any) => {
          const newToken = res.rtcToken
          webClient.rtc.renewToken(newToken);
          console.log('[agora-web] onTokenPrivilegeDidExpire', evt);
        })
      });
      webClient.rtc.on('error', (evt: any) => {
        console.log('[agora-web] error evt', evt);
      });
      // webClient.rtc.on('stream-published', ({ stream }: any) => {
      // });
      webClient.rtc.on('stream-subscribed', ({ stream }: any) => {
        const streamID = stream.getId();
        webClient.setRemoteVideoStreamType(stream, 1);
        const _stream = new AgoraStream(stream, stream.getId(), false);
        console.log('[agora-web] subscribe remote stream, id: ', stream.getId());
        roomStore.addRemoteStream(_stream);
      });
      webClient.rtc.on('stream-added', ({ stream }: any) => {
        console.log('[agora-web] added remote stream, id: ', stream.getId());
        webClient.subscribe(stream);
      });
      webClient.rtc.on('stream-removed', ({ stream }: any) => {
        console.log('[agora-web] removed remote stream, id: ', stream.getId());
        // const id = stream.getId();
        roomStore.removeRemoteStream(stream.getId());
      });
      webClient.rtc.on('peer-online', ({uid}: any) => {
        console.log('[agora-web] peer-online, id: ', uid);
        roomStore.addRTCUser(uid);
      });
      webClient.rtc.on('peer-leave', ({ uid }: any) => {
        console.log('[agora-web] peer-leave, id: ', uid);
        roomStore.removePeerUser(uid);
        roomStore.removeRemoteStream(uid);
      });
      webClient.rtc.on('stream-fallback', ({ uid, attr }: any) => {
        const msg = attr === 0 ? 'resume to a&v mode' : 'fallback to audio mode';
        console.info(`[agora-web] stream: ${uid} fallback: ${msg}`);
      })
      rtc.current = true;
      // WARN: IF YOU ENABLED APP CERTIFICATE, PLEASE SIGN YOUR TOKEN IN YOUR SERVER SIDE AND OBTAIN IT FROM YOUR OWN TRUSTED SERVER API
      webClient
        .joinChannel({
          uid: +roomState.me.uid, 
          channel: roomState.confState.channelName,
          token: roomState.me.rtcToken,
          dual: enableDual,
          appId: roomState.confState.appID
        }).then(() => {
          
        }).catch(console.warn).finally(() => {
          rtc.current = false;
        });
      return () => {
        const events = [
          'onTokenPrivilegeWillExpire',
          'onTokenPrivilegeDidExpire',
          'error',
          'stream-published',
          'stream-subscribed',
          'stream-added',
          'stream-removed',
          'peer-online',
          'peer-leave',
          'stream-fallback'
        ]
        for (let eventName of events) {
          webClient.rtc.off(eventName, () => {});
        }
        console.log('[agora-web] remove event listener');
        !rtc.current && webClient.exit().then(() => {
          console.log('[agora-web] do remove event listener');
        }).catch(console.warn)
          .finally(() => {
            rtc.current = true;
            roomStore.removeLocalStream();
          });
      }
  }, [JSON.stringify([roomState.me.uid, roomState.confState.channelName])]);


}