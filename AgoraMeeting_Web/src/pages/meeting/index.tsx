import React, { useState, useEffect, useMemo, useCallback, useRef } from 'react'
import './index.scss'
import { t } from '@/i18n'
import { useHistory, useLocation } from 'react-router-dom'
import { LectorLobbyLayout } from '@/components/lector-lobby-layout/index'
import { LectorTileLayout } from '@/components/lector-tile-layout/index'
import { ChatDrawerBox } from '@/components/drawer-box/chat'
import { MemberDrawerBox } from '@/components/drawer-box/members'
import { globalStore } from '@/stores/global'
import { roomStore } from '@/stores/room'
import { InviteDialog } from '@/components/invite/index'
import { useRoomState } from '@/containers/root-container'
import * as moment from 'moment'
import { useWebRTC } from '@/hooks/use-rtc'
import { ClickAwayListener } from '@material-ui/core'

interface MeetingMenuBtnProps {
  type: string
  messageCount?: number
  value: boolean
  disable?: boolean
  onClick?: (evt: any) => any
}

const MeetingMenuBtn: React.FC<MeetingMenuBtnProps> = (props) => {

  const className = `meeting-menu-icon ${props.type} ${props.value ? 'icon-active' : ''} ${props.disable ? 'disabled' : ''}`

  const handleClick = props.onClick ? props.onClick : () => {}

  return (
    <div className='meeting-menu-item'>
      <i className={className} id={props.type} onClick={handleClick}></i>
      <span className='item-title'>{t(`meeting.menu.${props.type}`)}</span>
      {props.children ? props.children : null}
    </div>
  )
}


const EndMeeting = () => {

  const me = useRoomState().me

  const isHost = me.role === 1

  const handleQuit = async () => {

    const amHost = roomStore.state.me.role === 1

    if (amHost) {
      globalStore.showDialog({
        type: 'EndMeeting',
        message: t('meeting.quit_confirm'),
        mask: false,
      })
    } else {
      globalStore.showDialog({
        type: 'EndMeetingForAudience',
        message: t('meeting.leave_confirm'),
        mask: false,
      })
    }
  }

  const QuitDialog = () => {
    // await roomStore.exitRoom()
    // history.push('/')
  }

  return (
    <div className='end-meeting' onClick={handleQuit}>
      <span className='item-title'>{isHost ? t(`meeting.menu.end-meeting`) : t(`meeting.menu.leave-meeting`)}</span>
    </div>
  )
}

const useRoomManager = () => {
  const history = useHistory()

  useEffect(() => {
    if (roomStore.state.rtm.joined) return
    globalStore.showLoading()
    roomStore.fetchAndLoginRTM()
    .catch((err: any) => {
      globalStore.showToast({
        type: 'meeting',
        message: t('meeting.need_login')
      })
      history.push('/')
    })
    .finally(() => {
      globalStore.stopLoading()
    })
  }, [roomStore, history])


  useEffect(() =>{
    return () => {
      if (!roomStore.state.rtm.joined) return
      roomStore.exitAll()
    }
  }, [])

  const [time, setTime] = useState(moment.utc(
    Math.abs(Date.now()-roomStore.state.confState.startTime)
    ).format('HH:mm:ss'))

  const intervalRef = useRef<any>(null)

  useEffect(() => {
    intervalRef.current = setInterval(() => {
      setTime(moment.utc(
        Math.abs(Date.now()-roomStore.state.confState.startTime)
        ).format('HH:mm:ss'))
    }, 1000)
    return () => {
      clearInterval(intervalRef.current)
    }
  }, [setTime])

  return {
    time
  }
}

export const MeetingPages = () => {

  const roomState = useRoomState()

  const inviteDialog = roomState.inviteDialog

  const roomName = roomState.confState.roomName

  const roomId = roomState.confState.roomId

  const password = roomState.sessionInfo.password

  const myName = roomState.sessionInfo.userName

  const location = useLocation()

  const inviterUrl = useMemo(() => {
    return `${[`${window.location.origin}${window.location.pathname}`, 'roomId=:roomId'].join('?').replace(':roomId', roomState.confState.roomId)}`
  }, [roomState.confState.roomId])

  // useEffect(() => {
  //   if (roomState.confState.muteAllAudio === 2) {
  //     globalStore.showToast({
  //       type: 'unmuteAudio',
  //       message: t('meeting.unmute_audio'),
  //     })
  //   } else {
      
  //   }
  // }, [roomState.confState.muteAllAudio])

  useWebRTC(roomState)

  const {time} = useRoomManager()

  const layoutClasses = [
    'lector-lobby',
    'lector-tile-layout'
  ]
  const [layout, setLayout] = useState<number>(0)
  const layoutClass = layoutClasses[layout]

  const showDrawer = 
      +roomState.meetingState.drawerChat |
      +roomState.meetingState.drawerMember

  const changeChatDrawer = (evt: any) => {
    const state = !!roomStore.state.meetingState.drawerChat
    roomStore.setDrawerChat(!state)
  }

  const changeMemberDrawer = (evt: any) => {
    const state = !!roomStore.state.meetingState.drawerMember
    roomStore.setDrawerMember(!state)
  }

  const handleSwitchLayout = (evt: any) => {
    // setLayout(+(!layout))
  }

  const handleMaximum = (evt: any) => {

  }

  const [focused, setFocused] = useState<boolean>(false)

  const closeMemberDrawerBox = async (evt: any) => {
    roomStore.setDrawerMember(false)
  }

  const closeChatDrawerBox = async (evt: any) => {
    roomStore.setDrawerChat(false)
  }

  const handleVideoState = async (evt: any) => {
    const state = !!roomStore.state.me.video
    await roomStore.updateLocalVideoState(!state)
  }

  const handleAudioState = async (evt: any) => {
    const state = !!roomStore.state.me.audio
    const myRole = roomStore.state.me.role

    if (state === false) {
      if (myRole === 1 || myRole === 2 && roomStore.state.confState.muteAllAudio !== 2) {
        await roomStore.updateLocalAudioState(!state)
      }
      if (myRole !== 1 &&
        roomStore.state.confState.muteAllAudio === 2) {
        globalStore.showDialog({
          type: 'applyAudio',
          message: t('meeting.ctrl.apply.audio'),
          showCancel: true,
          showConfirm: true,
          confirmText: '确定',
          cancelText: '取消'
        })
      }
    } else {
      await roomStore.updateLocalAudioState(!state)
    }
  }

  const toggleShare = async (evt: any) => {
    if (!evt.target || !evt.target.dataset) return
    if (evt.target.dataset['share'] === 'share-screen') {
      try {
        globalStore.showLoading()
        await roomStore.startWebScreenShare()
        await roomStore.toggleShare('shareScreen')
      } finally {
        globalStore.stopLoading()
      }
      return 
    }

    if (evt.target.dataset['share'] === 'share-board') {
      try {
        globalStore.showLoading()
        await roomStore.toggleShare('shareBoard')
      } finally {
        globalStore.stopLoading()
      }
      return 
    }
  }

  const alreadyShared = useMemo(() => {
    if (!!roomState.confState.shareBoard || !!roomState.confState.shareScreen) {
      return true
    }
    return false
  }, [roomState.confState.shareBoard, roomState.confState.shareScreen])

  useEffect(() => {
    if (!alreadyShared) {
      roomStore.setMaximum(false)
    }
  }, [alreadyShared])


  const handleShareMenu = useCallback((evt: any) => {
    if (alreadyShared) {
      globalStore.showToast({
        type: 'showToast',
        message: t('meeting.already_shared')
      })
      return console.warn('You are sharing board or screen, please stop first!')
    }
    toggleShare(evt)
  }, [alreadyShared])

  const toggleShareMenu = () => {
    roomStore.toggleShareMenu()
  }

  const showInviteDialog = useCallback((evt: any) => {
    roomStore.toggleInviteDialog()
  }, [roomState.inviteDialog, roomStore])

  const handleShareMenuClickAway = (evt: any) => {
    roomStore.toggleShareMenu()
  }
  return (
    <div className='meeting-container'>
      <div className={`meeting-page ${layoutClass} ${focused ? 'focused' : ''}`} onClick={() => {
        // setFocused(!focused)
      }}>
        <section className='meeting-nav ztop'>
          <div className='meeting-head'>
            <span className='meeting-title'>{roomState.confState.roomName}</span>
            <span className='meeting-current-time'>{time}</span>
            <i className='meeting-icon meeting-share' onClick={showInviteDialog}></i>
          </div>
          <div className='meeting-layout-config'>
            <div className='meeting-btn' onClick={handleSwitchLayout}>
              <i className='meeting-icon switch-layout-icon'></i>
              <span className='meeting-title'>{layout ? '平铺视图' : '演讲者视图'}</span>
            </div>
            {/* <div className='meeting-btn' onClick={handleMaximum}>
              <i className='meeting-icon maximum-icon'></i>
            </div> */}
          </div>
        </section>
        <article className={`meeting-content ${layoutClass}`}>
          {layoutClass === 'lector-lobby' ? <LectorLobbyLayout />: null}
          {layoutClass === 'lector-tile-layout' ? <LectorTileLayout />: null}
        </article>
        <div className="relative">
          <section className='meeting-menu ztop'>
            <div className='meeting-btn-groups'>
              <div className='meeting-icons'>
                <MeetingMenuBtn type='audio' value={Boolean(roomState.me.audio)} onClick={handleAudioState} />
                <MeetingMenuBtn type='video' value={Boolean(roomState.me.video)} onClick={handleVideoState}/>
                <MeetingMenuBtn type='screen-share' value={Boolean(roomState.meetingState.showShareMenu)} onClick={toggleShareMenu} />
                {/* <MeetingMenuBtn type='recording' value={false} disable /> */}
                <MeetingMenuBtn type='chat' value={Boolean(roomState.meetingState.drawerChat)} onClick={changeChatDrawer}>
                  {roomState.messageCount ? <div className="message-count">{roomState.messageCount}</div>: null}
                </MeetingMenuBtn>
                <MeetingMenuBtn type='members' value={Boolean(roomState.meetingState.drawerMember)} onClick={changeMemberDrawer} />
              </div>
              <EndMeeting />
            </div>
          </section>
          {Boolean(roomState.meetingState.showShareMenu) ?
          <ClickAwayListener onClickAway={handleShareMenuClickAway}>
            <div className={`share-btn-menu`} onClick={handleShareMenu}>
              <div className="share-items" data-share={'share-screen'}>
                <div className="share-screen-icon" data-share={'share-screen'}>
                </div>
                <span className="share-title" data-share={'share-screen'}>{t('meeting.screen_share')}</span>
              </div>
              <div className="share-items" data-share={'share-board'}>
                <div className="share-board-icon" data-share={'share-board'}>
                </div>
                <span className="share-title" data-share={'share-board'}>{t('meeting.board_share')}</span>
              </div>
            </div>
          </ClickAwayListener> : null}
        </div>
      </div>
      <div className={`meeting-drawer ${!!showDrawer ? 'drawer': ''}`}>
        {roomState.meetingState.drawerMember ?
          <MemberDrawerBox
            muteAllAudio={roomState.confState.muteAllAudio}
            memberCount={roomState.users.onlineUsers}
            title={t('meeting.member-list')}
            onClose={closeMemberDrawerBox}
          /> : null}
        {roomState.meetingState.drawerChat ?
          <ChatDrawerBox
            title={t('meeting.chat.title')}
            onClose={closeChatDrawerBox} 
          /> : null}
      </div>
      {inviteDialog ? 
        <InviteDialog
          roomName={roomName}
          roomId={roomId}
          password={password}
          className={'className'}
          inviterName={myName}
          inviterUrl={inviterUrl}
        /> : null}
    </div>
  )
}

export default () => (<MeetingPages />)