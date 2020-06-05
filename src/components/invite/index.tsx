import React from 'react'
import { t } from '@/i18n'
import CopyToClipboard from 'react-copy-to-clipboard'
import { globalStore } from '@/stores/global'
import './index.scss'
import { roomStore } from '@/stores/room'
import ClickAwayListener from '@material-ui/core/ClickAwayListener';

export const InviteDialog: any = ({
  roomName = '',
  className = '',
  password = '',
  inviterName = '',
  inviterUrl = '',
}: any) => {

  const handleClickOutside = (evt: any) => {
    roomStore.removeInviteDialog()
  }

  return (
    <ClickAwayListener onClickAway={handleClickOutside}>
      <div className={`invite-container ${className ? className : ''}`}>
        <div className="invite-list">
          <div className="invite-row">
            <span className="label">{t('meeting.inviteDialog.roomName')}</span>
            <span>{roomName}</span>
          </div>
          <div className="invite-row">
            <span className="label">{t('meeting.inviteDialog.inviterName')}</span>
            <span>{inviterName}</span>
          </div>
          <div className="invite-row">
            <span className="label">{t('meeting.inviteDialog.password')}</span>
            <span className="label">{password}</span>
          </div>
          <div className="invite-row">
            <span className="label">{t('meeting.inviteDialog.inviterUrl')}</span>
            <span className="inviter-url">{inviterUrl}</span>
          </div>
          <div className="invite-row align-self">
            <CopyToClipboard onCopy={() => {
              globalStore.showToast({
                type: 'notice',
                message: t('meeting.copy.success')
              })
            }} text={
`会议名：${roomName}
密码：${password}
邀请人：${inviterName}
web端：${inviterUrl}
Android下载链接：https://download.agora.io/demo/release/app-AgoraMeeting-release.apk
iOS下载链接：https://itunes.apple.com/cn/app/id1515428313`
            }>
              <div className="invite-link-btn">
                {t('meeting.copy.link')}
              </div>
            </CopyToClipboard>
          </div>
        </div>
      </div>
    </ClickAwayListener>
  )
}