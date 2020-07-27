import React, { useEffect, useState, useRef, useCallback, useMemo } from 'react'
import './audio.scss'
import { DeviceSelect } from '@/components/meeting-select'
import { VoiceVolume } from '@/components/volume/voice'
import { createAudioStream, getMicrophoneDevices } from '@/utils/agora-web-client'
import { CheckBoxAudio } from '@/components/checkbox'
import { debounce } from 'lodash'
import { t } from '@/i18n'
import { roomStore } from '@/stores/room'

const useAudio = () => {

  const init = useRef<boolean>(true)

  const [, setForceUpdate] = useState<any>({})

  const [microphoneList, setMicrophoneList] = useState<any[]>([])
  const [microphoneIdx, setMicrophoneIdx] = useState<number>(roomStore.state.mediaDevice.microphoneIdx)
  const [stream, setStream] = useState<any>(null)

  const [volume, setVolume] = useState<number>(0);

  const microphoneOnChange = useCallback((index: number) => {
    setMicrophoneIdx(index)
  }, [setMicrophoneIdx])

  useEffect(() => {
    return () => {
      init.current = false;
    }
  }, []);

  useEffect(() => {
    return () => {
      stream && stream.close()
    }
  }, [stream])

  useEffect(() => {
    const microphone = microphoneList[microphoneIdx]
    if (microphone && microphone.deviceId) {
      createAudioStream(microphone.deviceId)
      .then((stream: any) => {
        if (init.current) {
          setStream(stream)
          roomStore.setMicrophoneIdx(microphoneIdx)
        } else {
          stream.close()
        }
      }).catch((err: any) => {
        console.warn(err)
        init.current && setStream(null)
      })
    }
  }, [microphoneList, microphoneIdx, setStream])

  useEffect(() => {
    getMicrophoneDevices().then((deviceList: any) => {
      init.current && setMicrophoneList(deviceList)
    })
    navigator.mediaDevices.addEventListener('devicechange', debounce((evt: any) => {
      getMicrophoneDevices().then((deviceList: any) => {
        init.current && setMicrophoneList(deviceList) && setForceUpdate({})
      })
    }, 1000))
    return () => {
      navigator.mediaDevices.removeEventListener('devicechange', () => {
        getMicrophoneDevices().then((deviceList: any) => {
          init.current && setMicrophoneList(deviceList)
        })
      })
    }
  }, [])

  const interval = useRef<any>(null);

  useEffect(() => {
    if (!stream || !stream.getAudioLevel) return;
    interval.current = setInterval(() => {
      init.current && setVolume(stream.getAudioLevel())
    }, 300);
    return () => {
      interval.current && clearInterval(interval.current);
      interval.current = null;
    }
  }, 
  // eslint-disable-next-line
  [stream]);

  return {
    stream,
    volume,
    microphoneIdx,
    microphoneList,
    microphoneOnChange
  }
}


const AudioVolumeIndicator: React.FC<any> = ({volume}) => {
  return (
    <div>
      <VoiceVolume volume={volume} />
    </div>
  )
}

export const AudioTestPage = () => {
  const {volume, microphoneIdx, microphoneList, microphoneOnChange} = useAudio()

  const [play, setPlay] = useState<boolean>(false)

  const $audio = useRef<any>(null)

  const stopAudio = (player: HTMLMediaElement) => {
    player.pause()
    player.currentTime = 0
  }

  const startAudio = (player: HTMLMediaElement) => {
    player.play()
  }

  const handlePlay = () => {
    if ($audio.current) {
      play ? stopAudio($audio.current): startAudio($audio.current)
    }
  }

  useEffect(() => {
    if ($audio.current && setPlay) {
      const onAudioPaused = () => {
        $audio.current && setPlay(false)
      }

      const onAudioPlaying = () => {
        $audio.current && setPlay(true)
      }

      $audio.current.addEventListener('pause', onAudioPaused)
      $audio.current.addEventListener('ended', onAudioPaused)
      $audio.current.addEventListener('playing', onAudioPlaying)
      return () => {
        $audio.current.removeEventListener('pause', () => {})
        $audio.current.removeEventListener('ended', () => {})
        $audio.current.removeEventListener('playing', () => {})
      }
    }
  }, [$audio, setPlay])

  return (
    <div className='partial-page audio-page'>
      <section className='audio-item margin-bottom-20px'>
        <div className='text-label'>
          {t('audio.input')}
        </div>
        <div className='items'>
          <DeviceSelect
            onChange={(evt: any) => {
              microphoneOnChange(evt.target.value)
            }}
            value={microphoneIdx}
            className='audio-devices-select'
            items={microphoneList} 
           />
          <AudioVolumeIndicator volume={volume} />
        </div>
      </section>
      <section className='audio-item-cols'>
        <div className='audio-sub-item playout-row'>
          <span className='text-label'>{t('audio.output')}</span>
          <div className='items'>
            <a onClick={handlePlay} className={`audio-btn ${play ? 'audio-paused' : 'audio-play'}`} />
            <audio ref={$audio} id='audio' src='https://webdemo.agora.io/test_audio.mp3' style={{'display': 'none'}}></audio>
          </div>
        </div>
        <div className='audio-sub-item audio-check'>
          <CheckBoxAudio /> 
        </div>
      </section>
    </div>
  )
}