import React, { useEffect, useState, useMemo, useRef, useCallback } from 'react'
import './video.scss'
import { DeviceSelect } from '@/components/meeting-select'
import { createVideoStream, getCameraDevices } from '@/utils/agora-web-client'
import { roomStore } from '@/stores/room'
import { CheckBoxVideo } from '@/components/checkbox'
import { debounce } from 'lodash'
import { t } from '@/i18n'

const VideoPreview: React.FC<any> = ({
  stream,
  preview,
  domId,
}) => {

  useEffect(() => {
    if (!stream || !domId || 
    stream.isPlaying()) return;
    stream.play(`${domId}`, { fit: 'cover' }, (err: any) => {
      console.warn('[video-player] ', JSON.stringify(err), stream.isPaused(), stream.isPlaying());
    })
    return () => {
      if (stream.isPlaying()) {
        stream.stop();
      }
      if (preview) {
        stream.close();
      }
    }
  }, [domId, stream]);

  const InternalClass = preview ? 'preview-stream' : ''

  return (
    <div className={`agora-video-player ${InternalClass}`}>
      {stream ? <div id={`${domId}`}></div> : null}
    </div>
  )
}

const useCameraDevice = () => {

  const init = useRef<boolean>(true)

  const [, setForceUpdate] = useState<any>({})

  const [cameraList, setCameraList] = useState<any[]>([])
  const [cameraIdx, setCameraIdx] = useState<number>(roomStore.state.mediaDevice.cameraIdx)
  const [stream, setStream] = useState<any>(null)

  const cameraOnChange = useCallback((index: number) => {
    init.current && setCameraIdx(index)
  }, [setCameraIdx])

  useEffect(() => {
    return () => {
      init.current = false
    }
  }, [])

  useEffect(() => {
    return () => {
      stream && stream.close()
    }
  }, [stream])

  useEffect(() => {
    const camera = cameraList[cameraIdx]
    if (camera && camera.deviceId) {
      createVideoStream(camera.deviceId)
      .then((stream: any) => {
        if (init.current) {
          setStream(stream)
          roomStore.setCameraIdx(cameraIdx)
        } else {
          stream.close()
        }
      }).catch((err: any) => {
        console.warn(err)
        init.current && setStream(null)
      })
    }
  }, [cameraList, cameraIdx, setStream])

  useEffect(() => {
    getCameraDevices().then((deviceList: any) => {
      init.current && setCameraList(deviceList)
    })
    navigator.mediaDevices.addEventListener('devicechange', debounce(() => {
      getCameraDevices().then((deviceList: any) => {
        init.current && setCameraList(deviceList) && setForceUpdate({})
      })
    }, 1000))
    return () => {
      navigator.mediaDevices.removeEventListener('devicechange', () => {
        getCameraDevices().then((deviceList: any) => {
          init.current && setCameraList(deviceList)
        })
      })
    }
  }, [])

  return {
    cameraList,
    stream,
    cameraIdx,
    cameraOnChange
  }
}

export const VideoTestPage = () => {
  const {cameraList, cameraIdx, stream, cameraOnChange} = useCameraDevice()
  return (
    <div className='partial-page video-page'>
      <section className='video-item margin-bottom-20px'>
        <div className='text-label'>
          {t('video.preview')}
        </div>
        <VideoPreview stream={stream} preview={true} domId='local' />
      </section>
      <section className='video-item-cols'>
        <div className='video-sub-item'>
          <span className="text-label">{t('video.input')}</span>
          <DeviceSelect
            onChange={(evt: any) => {
              console.log("cameraList", cameraList, evt.target.value)
              cameraOnChange(evt.target.value)
            }}
            value={cameraIdx}
            className='video-devices-select'
            items={cameraList}
          ></DeviceSelect>
        </div>
        <div className='video-sub-item video-check'>
          <CheckBoxVideo />
        </div>
      </section>
    </div>
  )
}