import React, { useEffect , useState, useMemo, useCallback } from 'react'
import '../index.scss'
import { MediaStateIcon } from '@/components/media-state-icons'
import { MediaDropDownMenu, OutSideMediaDropDownMenu } from '@/components/dropdown-menu'
import { AgoraUser, roomStore } from '@/stores/room'
import { t } from '@/i18n'
import { globalStore } from '@/stores/global'
import { InviteDialog } from '@/components/invite/index'
import { useRoomState } from '@/containers/root-container'
import { useRoom } from '@/hooks/use-room'

interface MemberRowProps {
  member: any
  muteAllAudio: number
}

const MemberRow = (props: MemberRowProps) => {

  const isOwner = roomStore.state.confState.createBoardUserId === props.member.userId

  const isScreenOwner = props.member.grantScreen

  const colors = [
    'red', 'green', 'blue', 'default'
  ]

  const pickColor = colors[+props.member.role % 4]

  const color = pickColor ? pickColor : 'default'

  const extraInfo = useMemo(() => {
    return props.member.userId === roomStore.state.me.userId ? '(我)' : ''
  }, [props.member.userId])

  const extraName = useMemo(() => {
    if (props.member.role === 1) return '(主持人)'
  }, [props.member.role])


  const [showMenu, setShowMenu] = useState<boolean>(false)

  const handleDropMenuClick = (evt: any) => {
    setShowMenu(true)
  }

  const handleOutsideDropMenuClick = (evt: any) => {
    setShowMenu(false)
  }

  return (
    <div className='member-cell'>
      <div className='member-row'>
        <div className='member-profile'>
          <span className={`avatar ${color}`}></span>
          <span className='member-name'>{props.member.userName}</span>
          {extraInfo && (<span className='my'>{extraInfo}</span> )}
          {extraName && (<span className='isHost'>{extraName}</span>)}
        </div>
        <div className='member-states'>
          {/* <MediaStateIcon
            className={props.member.role === 1 ? 'roleHost': ''}
          /> */}
          {isScreenOwner ? <MediaStateIcon
            className={'shareScreen'}
          /> : null }
          {isOwner ? <MediaStateIcon
            className={'shareBoard'}
          /> : null }
          {!isOwner && props.member.grantBoard ? 
            <MediaStateIcon
              className={'interactiveBoard'}
            /> : null }
          <MediaStateIcon
            className={props.member.video === 1 ? 'unmuteVideo': 'muteVideo'}
          />
          <MediaStateIcon
            className={props.member.audio === 1 ? 'unmuteAudio': 'muteAudio'}
            onClick={() => {
              const myRole = roomStore.state.me.role
              const myUserId = roomStore.state.me.userId
              if (myRole === 1 
                || props.member.userId === myUserId) {
                setShowMenu(true)
              }
          }}
          />
        </div>
      </div>
      <OutSideMediaDropDownMenu 
        isHost={props.member.isHost}
        isBoardOwner={props.member.isBoardOwner}
        isMe={props.member.isMe}
        createBoardUserId={props.member.createBoardUserId}
        showMenu={showMenu}
        onClick={handleDropMenuClick}
        handleClickOutSide={handleOutsideDropMenuClick}
        muteAllAudio={props.muteAllAudio}
        video={props.member.video}
        audio={props.member.audio}
        chat={props.member.chat}
        grantBoard={props.member.grantBoard}
        role={props.member.role}
        userId={props.member.userId}
        uid={props.member.uid}
      />
    </div>
  )
}

const MemberItem = React.memo(MemberRow)

export const MemberDrawerBox = (props: any) => {

  const {members, roomState} = useRoom()

  const myRole = roomState.me.role
  const isHost = myRole === 1
  const inviteDialogBottom = roomState.inviteDialogBottom
  const roomName = roomState.confState.roomName

  const roomId = roomState.confState.roomId

  const password = roomState.sessionInfo.password

  const myName = roomState.sessionInfo.userName

  const inviterUrl = useMemo(() => {
    return `${[`${window.location.origin}${window.location.pathname}`, 'roomId=:roomId'].join('?').replace(':roomId', roomState.confState.roomId)}`
  }, [roomState.confState.roomId])

  const sendInvite = async () => {
    // await confApi.updateGlobalRoomState()
  }

  const sendMuteAllAudio = useCallback((evt: any) => {
    if (props.muteAllAudio === 0) {
      globalStore.showDialog({
        type: 'MuteAllAudio',
        message: t('meeting.mute_room_audio'),
        mask: false
      })
    } else {
      globalStore.showDialog({
        type: 'UnmuteAllAudio',
        message: t('meeting.unmute_room_audio'),
        mask: false
      })
    }
  }, [props.muteAllAudio])


  const toggleInviteDialog = () => {
    roomStore.toggleInviteFromBottom()
  }

  return (
    <div className='drawer-box' style={{'position': 'relative'}}>
      <div className='drawer-header'>
        <span>{props.title ? props.title : ''}({members.length})</span>
        <span className='close' onClick={props.onClose}></span>
      </div>
      <div className='drawer-body'>
        <div className='scrollable-container'>
          <div className='member-list'>
            <div className='member-table'>
              {
                members.map((member: any, index: number) => (
                  <MemberItem key={index} member={member} muteAllAudio={props.muteAllAudio} />
                ))
              }
            </div>
          </div>
        </div>
      </div>
      <div className='member-btn-group'>
        <div className='member-btn invite' onClick={toggleInviteDialog}>{t('meeting.invite')}</div>
        {
          isHost ?
          <>
            <div className={`member-btn muteAllVoice`} onClick={sendMuteAllAudio}>
              {props.muteAllAudio === 0 ? t('meeting.muteAllAudio') : t('meeting.unmuteAllAudio')}
            </div>
          </> : null
        }
      </div>
      {
        inviteDialogBottom ? 
        <InviteDialog 
          roomName={roomName}
          roomId={roomId}
          password={password}
          className={'invite-drawer'}
          inviterName={myName}
          inviterUrl={inviterUrl}
        /> : null
      }
    </div> 
  )
}