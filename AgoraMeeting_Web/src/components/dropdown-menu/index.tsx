import React, { useMemo, useCallback, useState } from 'react'
import { t } from '@/i18n'
import { DropDownBtn } from '@/components/custom-dropdown-btn'
import { useRoomState } from '@/containers/root-container'
import { roomStore } from '@/stores/room'
import './index.scss'
import { MeetingMessageType } from '@/utils/agora-rtm-client'
import { ClickAwayListener } from '@material-ui/core'

const CustomMenuList = ({
  createBoardUserId,
  userId,
  uid,
  role,
  audio,
  video,
  chat,
  grantBoard,
  muteAllAudio,
  isBoardOwner,
  isMe,
  isHost
}: any) => {

  const notSharing = createBoardUserId === '0'

  const meIsOwner = isBoardOwner

  const CanIEnableAudio = (isMe && muteAllAudio !== 2) || (isMe && muteAllAudio === 2 && isHost) || (isMe && muteAllAudio === 2 && !!audio) ? true : false

  const CanIApplyAudio = isMe && (!isHost && muteAllAudio === 2) ? true : false

  const CanIApplyBoard = !notSharing && isMe && !!grantBoard === false && !isHost && !meIsOwner ? true : false

  const CanIEnableVideo = isMe ? true : false

  const CanIGrantRole = isHost && !isMe ? true : false

  const CanIGrantBoard = meIsOwner && !isMe

  const CanIKickUser = !isMe && isHost

  const CanICancelBoard = isMe && meIsOwner && !!grantBoard === true ? true : false

  const CanIEnableInviteAudio = !isMe && isHost ? true : false
  
  const CanIEnableInviteVideo = !isMe && isHost ? true : false

  const clickAudio = async () => {
    await roomStore.updateUserMediaState(
      userId,
      MeetingMessageType.audio,
      !audio
    )
  }

  const clickVideo = async () => {
    await roomStore.updateUserMediaState(
      userId,
      MeetingMessageType.video,
      !video
    )
  }

  const clickRole = async () => {
    await roomStore.setNewHostUserBy(
      userId,
    )
  }

  const clickBoard = async () => {
    await roomStore.setGrantBoard(
      userId
    )
  }

  const handleInviteAudio = async () => {
    const rawValue = !!audio
    if (rawValue) {
      await roomStore.updateUserMediaState(userId, MeetingMessageType.audio, !rawValue, false)
    } else {
      await roomStore.hostSendInvite(userId, MeetingMessageType.audio, +!rawValue)
    }
  }

  const handleInviteVideo = async () => {
    const rawValue = !!video
    if (rawValue) {
      await roomStore.updateUserMediaState(userId, MeetingMessageType.video, !rawValue, false)
    } else {
      await roomStore.hostSendInvite(userId, MeetingMessageType.video, +!rawValue)
    }
  }

  const handleInviteBoard = async () => {
    // await roomStore.inviteBoard()
  }

  const handleApplyBoard = async () => {
    await roomStore.applyBoard()
  }

  const handleApplyAudio = async () => {
    await roomStore.applyAudio(userId, MeetingMessageType.audio)
  }

  const clickKick = async () => {
    await roomStore.kickUserBy(userId)
  }

  const handleCancelBoard = async () => {
    await roomStore.cancelBoard(userId)
  }

  return (
    <>
      {CanIEnableAudio ? <DropDownBtn text='audio' value={audio} onClick={clickAudio} /> : null}

      {CanIApplyAudio && !audio ? <DropDownBtn text='apply_audio' value={audio} onClick={handleApplyAudio} /> : null}

      {CanIEnableInviteAudio ? <DropDownBtn text='invite_audio' value={audio} onClick={handleInviteAudio} /> : null}

      {CanIEnableVideo ? <DropDownBtn text='video' value={video} onClick={clickVideo} /> : null}

      {CanIEnableInviteVideo ? <DropDownBtn text='invite_video' value={video} onClick={handleInviteVideo} /> : null}

      {CanIGrantRole ? <DropDownBtn text='role' value={role === 1} onClick={clickRole} /> : null}

      {CanIApplyBoard ? <DropDownBtn text='apply_board' value={false} onClick={handleApplyBoard} /> : null}

      {CanICancelBoard ? <DropDownBtn text='cancel_board' value={false} onClick={handleCancelBoard} /> : null}
      {/* {CanIEnableInviteBoard && (<DropDownBtn text='grant_board' value={false} onClick={handleInviteBoard} />)} */}
      {CanIGrantBoard ? <DropDownBtn text='grant_board' value={grantBoard} onClick={clickBoard} /> : null}
      {CanIKickUser ? <DropDownBtn text='kick' value={true} onClick={clickKick} /> : null}
    </>
  )
}

const _MediaDropDownMenu: React.FC<any> = ({
  userId,
  grantBoard,
  video,
  audio,
  uid,
  chat,
  role,
  onClick,
  handleClickOutSide,
  hideIcon,
  isMe,
  isHost,
  isBoardOwner,
  createBoardUserId,
  muteAllAudio,
}) => {
  // const roomState = useRoomState()

  // const isMe = roomState.me.userId === userId

  // const isHost = roomState.me.role === 1

  const autoHideIcon = useMemo(() => {
    if (hideIcon) {
      return true
    }
    // when is mine
    if (isMe) {
      return false
    }
    // when am host
    if (isHost) {
      return false
    }
    return true
  }, [isMe, isHost, hideIcon])

  const handleClickAway = handleClickOutSide ? handleClickOutSide : () => {}

  return (
    <ClickAwayListener onClickAway={handleClickAway}> 

    <div className={`mediaDropdownBody`}>
      {
        autoHideIcon ? 
        null : <span className={'mediaCtrlIcon'} onClick={onClick}></span>
      }
      <div className={hideIcon ? 'visibleMediaMenu' : 'mediaMenu'}>
        <div className='menu-placeholder'></div>
        <div className='mediaMenuList'>
          <CustomMenuList
            isHost={isHost}
            isMe={isMe}
            isBoardOwner={isBoardOwner}
            createBoardUserId={createBoardUserId}
            muteAllAudio={muteAllAudio}
            uid={uid}
            userId={userId}
            grantBoard={Boolean(grantBoard)}
            video={Boolean(video)}
            audio={Boolean(audio)}
            chat={Boolean(chat)}
            role={role}
          />
        </div>
      </div>
    </div>
    </ClickAwayListener>

  )
}

export const MediaDropDownMenu = React.memo(_MediaDropDownMenu)

export const OutSideMediaDropDownMenu = (props: any) => {

  const showCtrl = props.isMe || props.isHost ? true : false

  return (
    <>
      <div className={'none'}>
        {showCtrl ? 
          <span className={'mediaCtrlActive'} onClick={props.onClick}></span>
          : null}
      </div>
      {props.showMenu ?
        <MediaDropDownMenu 
          hideIcon={true}
          {...props}
        />
        : null }
    </>
  )
}