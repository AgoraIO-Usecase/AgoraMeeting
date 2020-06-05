import React, { useEffect, useState, useMemo, useCallback } from 'react'
import { TextField, Box, ClickAwayListener } from '@material-ui/core'

import CustomButton from '@/components/custom-button'

import { useHistory } from 'react-router-dom'
import { CheckBoxVideo, CheckBoxAudio } from '@/components/checkbox'
import { confApi } from '@/services/meeting-api'
import { useRoomState } from '@/containers/root-container'
import { roomStore } from '@/stores/room'

import './index.scss'
import { genUUID } from '@/utils/api'
import { t } from '@/i18n'
import { globalStore } from '@/stores/global'

const FixedTextField = ({className, ...props}: any) => (
  <TextField className={`customize ${className}`} {...props} style={{width: '300px', height: '40px', marginBottom: '20px'}} />
)


const authSession = (info: any) => {
  const userName = info.userName
  const roomName = info.roomName
  const password = info.password

  // const res = ['', '', '']
  const result: any = {
    userNameErrMsg: '',
    roomNameErrMsg: '',
    passwordErrMsg: '',
  }

  if (userName !== undefined && (userName.length < 3 || userName.length > 20)) {
    result.userNameErrMsg = '用户名不得小于3个字符，也不能超过20个字符'
  }

  if (password !== undefined && (password.length > 50)) {
    result.passwordErrMsg = '房间密码不能超过50个字符'
  }

  if (roomName !== undefined && (roomName.length < 3 || roomName.length > 50)) {
    result.roomNameErrMsg = '房间名不得小于3个字符，也不能超过50个字符'
  }

  return {
    result,
    count: Object.keys(result).filter((key: string) => result[key].length).length
  }
}

export const LoginCard = () => {

  const params = new URLSearchParams(window.location.search)

  const roomId = params.get('roomId')

  const roomState = useRoomState()
  const history = useHistory()

  const {roomName, userName, password} = roomState.sessionInfo

  const mediaState = roomState.mediaState

  const [invalidState, setInvalidState] = useState<any>([])

  const EnterRoom = async (evt: any) => {
    try {
      const res = authSession(roomState.sessionInfo)
      if (res.count) {
        setInvalidState({
          ...res.result
        })
        return
      }
      globalStore.showLoading()
      await roomStore.LoginToRoom({
        userUuid: genUUID(),
        userName: userName,
        roomName: roomName,
        roomUuid: roomName,
        enableAudio: +mediaState.useMicrophone,
        enableVideo: +mediaState.useCamera,
        password: password ? password: ''
      })
      history.push('/meeting')
    } catch(err) {
      // throw err
      console.warn(err)
    } finally {
      globalStore.stopLoading()
    }
  }

  useEffect(() => {
    if (roomId) {
      roomStore.getRoomStateBy(roomId)
    }
  }, [roomId])

  return (
    <div className='login-card' onKeyPress={async (evt: any) => {
      if (evt.key === 'Enter') {
        evt.preventDefault()
        await EnterRoom(evt)
      }
    }}>
      <FixedTextField
        error={!!invalidState.roomNameErrMsg}
        helperText={invalidState.roomNameErrMsg}
        value={roomName ? roomName : ''}
        label={t('meeting.session.roomName')}
        variant='outlined'
        onChange={(evt: any) => {
          const value = evt.target.value
          if (value) {
            const {result} = authSession({
              roomName: value
            })
            setInvalidState({
              ...invalidState,
              roomNameErrMsg: result.roomNameErrMsg
            })
          }
          roomStore.changeSessionInfo({
            roomName: value
          })
        }}
      />
      <FixedTextField
        className={'customize-password'}
        error={!!invalidState.passwordErrMsg}
        helperText={invalidState.passwordErrMsg}
        value={password ? password : ''}
        label={t('meeting.session.password')}
        variant='outlined'
        onChange={(evt: any) => {
          const value = evt.target.value
          if (value) {
            const {result} = authSession({
              password: value
            })
            setInvalidState({
              ...invalidState,
              passwordErrMsg: result.passwordErrMsg
            })
          }
          roomStore.changeSessionInfo({
            password: value
          })
        }}
      />
      <FixedTextField
         error={!!invalidState.userNameErrMsg}
         helperText={invalidState.userNameErrMsg}
        value={userName ? userName : ''}
        label={t('meeting.session.userName')}
        variant='outlined'
        onChange={(evt: any) => {
          const value = evt.target.value
          if (value) {
            const {result} = authSession({
              userName: value
            })
            setInvalidState({
              ...invalidState,
              userNameErrMsg: result.userNameErrMsg
            })
          }
          roomStore.changeSessionInfo({
            userName: value
          })
        }}
      />
      <Box display='flex' flexDirection='row' alignItems='center'>
        <CheckBoxVideo />
      </Box>
      <Box display='flex' flexDirection='row' alignItems='center'>
        <CheckBoxAudio />
      </Box>
      <CustomButton onClick={EnterRoom} disableElevation={true} className='login-btn' name='加入'></CustomButton>
    </div>
  )
}

export const CardContainer = () => {

  const history = useHistory()

  const onClick = async () => {
    history.push('/setting')
  }

  const [note, setNote] = useState<boolean>(false)

  const hideNote = () => {
    setNote(false)
  }

  const toggleNote = useCallback((evt: any) => {
    setNote(!note)
  }, [note, setNote])

  return (
    <div className='login'>
      <div className='login-content'>
        <div className='setting'>
          <span className='setting-icon' onClick={onClick}></span>
        </div>
        <div className='content-header'>
          <img className='meeting-logo' alt='agora meeting logo'/>
          <span className='app-name'>Agora Meeting</span>
        </div>
        <LoginCard />
        <div className="home-notice-container">
          <ClickAwayListener onClickAway={hideNote}>
            <i className="home-notice" onClick={toggleNote}></i>
          </ClickAwayListener>
          <div className={`facade-notice ${note ? 'opacity-1' : 'opacity-0'}`}>
            <span className="triangle"></span>
            <ul>
              <li>房间已存在时，需要输入正确的密码</li>
              <li>房间不存在时，输入的密码将成为这个房间的密码</li>
              <li>房间可以不设置密码</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}

export const HomePage = () => (
  <div className='meeting-facade'>
    <CardContainer />
  </div>
)

export default () => (<HomePage />)