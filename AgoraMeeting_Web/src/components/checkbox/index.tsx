import React, {useMemo} from 'react'
import {roomStore} from '@/stores/room'
import { Checkbox, Typography } from '@material-ui/core'
import { useRoomState } from '@/containers/root-container'

const CheckVideo = (props: any) => (
  <>
    <Checkbox
      checked={props.checked}
      color='primary'
      onChange={() => {
        roomStore.setUseCamera(+(!props.checked))
      }}
    />
    <Typography variant='caption'
      onClick={() => {
        roomStore.setUseCamera(+(!props.checked))
      }}>
      打开摄像头
    </Typography>
  </>
)

export const CheckBoxVideo = () => {
  const roomState = useRoomState()
  return useMemo(() => {
    return CheckVideo({checked: Boolean(roomState.mediaState.useCamera)})
  }, [roomState.mediaState.useCamera])
}

const CheckAudio = (props: any) => (
  <>
    <Checkbox
      checked={props.checked}
      color='primary'
      onChange={() => {
        roomStore.setUseMicrophone(+(!props.checked))
      }}
    />
    <Typography variant='caption'
      onClick={() => {
        roomStore.setUseMicrophone(+(!props.checked))
      }}>
      打开麦克风
    </Typography>
  </>
)

export const CheckBoxAudio = () => {
  const roomState = useRoomState()
  return useMemo(() => {
    return CheckAudio({checked: Boolean(roomState.mediaState.useMicrophone)})
  }, [roomState.mediaState.useMicrophone])
}