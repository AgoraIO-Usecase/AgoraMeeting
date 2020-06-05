import React, {useMemo, useState} from 'react';
import Button from '@/components/custom-button';
import {Checkbox, Dialog, DialogContent, DialogContentText, Typography} from '@material-ui/core';

import './dialog.scss';
import { useGlobalState } from '@/containers/root-container';
import { roomStore } from '@/stores/room';
import { globalStore } from '@/stores/global';
import { useHistory } from 'react-router-dom';
// import { RoomMessage } from '@/utils/agora-rtm-client';
import { t } from '@/i18n';
import { confApi } from '@/services/meeting-api';
import { MeetingMessageType } from '@/utils/agora-rtm-client'

const CheckMuteAudio = (props: any) => (
  <>
    <Checkbox
      checked={props.checked}
      color='primary'
      onChange={props.onChange}
    />
    <Typography variant='caption'>
      允许参会者自我解除静音
    </Typography>
  </>
)

interface RoomProps {
  onConfirm: (type: string) => any
  onClose: (type: string) => any
  desc: string
  type: string
  mask: boolean
  showConfirm: boolean
  showCancel: boolean
  cancelText: string
  confirmText: string
}

function RoomDialog(
{
  onConfirm,
  onClose,
  desc,
  type,
  mask,
  showConfirm,
  showCancel,
  confirmText,
  cancelText
}: RoomProps) {

  const history = useHistory()

  const [checked, setChecked] = useState<boolean>(false)

  const handleClose = async () => {
    switch (type) {
      case 'hostInvite': {
        await roomStore.audienceRejectHostInvite()
        break
      }
      case 'audienceApply': {
        await roomStore.hostRejectAudienceInvite()
        break
      }
    }

    if (type === 'kickedOut') {
      onConfirm(type)
      history.push('/')
      return
    }

    // if (type === 'meetingAlreadyEnded') {
    //   onConfirm(type)
    //   history.push('/')
    //   return
    // }

    if (type === 'kickedOut') {
      onConfirm(type)
      history.push('/')
      return
    }
    onClose(type)
  }

  const handleConfirm = async () => {
    switch (type) {
      case 'exitRoom': {
        await roomStore.exitRoom()
        break;
      }
      case 'hostInvite': {
        await roomStore.audienceAcceptHostInvite()
        break
      }
      case 'audienceApply': {
        await roomStore.hostAcceptApply()
        break
      }
      case 'applyAudio': {
        await roomStore.applyAudio(roomStore.state.me.userId, MeetingMessageType.audio)
        break
      }
    }

    if (type === 'meetingAlreadyEnded') {
      onConfirm(type)
      history.push('/')
      return
    }

    if (type === 'kickedOut') {
      onConfirm(type)
      history.push('/')
      return
    }
    onConfirm(type)
  }

  const confirmQuitMeeting = async (evt: any) => {
    if (type === 'EndMeeting') {
      await roomStore.quitMeeting()
      globalStore.removeDialog()
      history.push('/')
    }

    if (type === 'EndMeetingForAudience') {
      await roomStore.quitMeeting()
      globalStore.removeDialog()
      history.push('/')
    }
  }

  const confirmEndMeeting = async (evt: any) => {
    if (type === 'EndMeeting') {
      await roomStore.exitAllAndEndMeeting()
      globalStore.removeDialog()
      history.push('/')
    }
  }

  const confirmMuteRoomAudio = async(evt: any) => {
    if (checked) {
      await roomStore.forceMuteAllAudio(false)
    } else {
      await roomStore.forceMuteAllAudio(true)
    }
    globalStore.removeDialog()
  }

  const confirmUnmuteRoomAudio = async (evt: any) => {
    await roomStore.sendUnmuteAllAudio()
    globalStore.removeDialog()
  }

  return (
    <Dialog
      className={`custom-dialog ${mask ? 'mask' : 'no-mask'}`}
      disableBackdropClick
      open={true}
      onClose={handleClose}
      aria-labelledby='alert-dialog-title'
      aria-describedby='alert-dialog-description'
    >
      <DialogContent
        className='modal-container'
      >
        <DialogContentText className='dialog-title'>
          {desc}
        </DialogContentText>
        {type === 'MuteAllAudio' ? 
          <div className={'box'}>
            <CheckMuteAudio
              checked={checked}
              onChange={() => {
                const val = !checked
                setChecked(!!val)
              }}
            />
          </div>
           : ''}
        <div className="margin-top-20px">
          {
            [
              'EndMeeting',
              'MuteAllAudio',
              'UnmuteAllAudio',
              'EndMeetingForAudience',
            ].indexOf(type) === -1
          &&
            (<div className="button-group">
              {showConfirm ? <Button name={confirmText ? confirmText : t('toast.confirm')} className='confirm' onClick={handleConfirm} color='primary' /> : null}
              {showCancel ? <Button name={cancelText ? cancelText : t('toast.cancel')} className='cancel' onClick={handleClose} color='primary' /> : null}
            </div>)
          }
          {
            type === 'EndMeeting' && (
              <div className="button-group meeting-btn-layouts">
                <Button name={t('toast.cancel')} className='cancel' onClick={handleClose} color='primary' />
                <Button name={t('toast.confirm_quit')} className='confirm' onClick={confirmQuitMeeting} color='primary' />
                <Button name={t('toast.confirm_end')} className='confirm' onClick={confirmEndMeeting} color='primary' />
              </div>
            )
          }
          {
            type === 'EndMeetingForAudience' && (
              <div className="button-group meeting-btn-layouts">
                <Button name={t('toast.cancel')} className='cancel' onClick={handleClose} color='primary' />
                <Button name={t('toast.confirm_quit')} className='confirm' onClick={confirmQuitMeeting} color='primary' />
              </div>
            )
          }
          {
            type === 'MuteAllAudio' && (
              <div className="button-group meeting-btn-layouts">
                <Button name={t('toast.cancel')} className='cancel' onClick={handleClose} color='primary' />
                <Button name={t('toast.confirm_mute')} className='confirm' onClick={confirmMuteRoomAudio} color='primary' />
                {/* <Button name={t('toast.confirm_force_mute')} className='confirm' onClick={confirmForceMuteRoomAudio} color='primary' /> */}
              </div>
            )
          }
          {
            type === 'UnmuteAllAudio' && (
              <div className="button-group meeting-btn-layouts">
                <Button name={t('toast.cancel')} className='cancel' onClick={handleClose} color='primary' />
                <Button name={t('toast.confirm_unmute_audio')} className='confirm' onClick={confirmUnmuteRoomAudio} color='primary' />
              </div>
            )
          }
        </div>
      </DialogContent>
    </Dialog>
  );
}

const DialogContainer = () => {

  const history = useHistory();
  const {dialog} = useGlobalState();

  const visible = useMemo(() => {
    if (!dialog.type) return false;
    return true;
  }, [dialog]);

  const onClose = (type: string) => {
    globalStore.removeDialog()
  }

  const onConfirm = (type: string) => {
    globalStore.removeDialog()
  }

  return (
    visible ? 
      <RoomDialog 
        type={dialog.type}
        desc={dialog.message}
        onClose={onClose}
        onConfirm={onConfirm}
        mask={dialog.mask}
        showConfirm={dialog.showConfirm}
        showCancel={dialog.showCancel}
        cancelText={dialog.cancelText as string}
        confirmText={dialog.confirmText as string}
      /> : 
      null
  )
}


export default React.memo(DialogContainer);