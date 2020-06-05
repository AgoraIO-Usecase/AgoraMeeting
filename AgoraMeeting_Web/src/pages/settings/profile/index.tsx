import React from 'react'
import { Input } from '@material-ui/core'
import './profile.scss'
import { roomStore } from '@/stores/room'
import { useRoomState } from '@/containers/root-container'
import { t } from '@/i18n'

export const ProfilePage = () => {

  const userName = useRoomState().sessionInfo.userName
  
  return (
    <div className='partial-page user-profile'>
      <span className="text-label">{t('meeting.session.userName')}</span>
      <Input
        className=''
        value={userName}
        onChange={(evt: any) => {
          roomStore.changeSessionInfo({
            userName: evt.target.value,
          })
        }}
      />
    </div>
  )
}