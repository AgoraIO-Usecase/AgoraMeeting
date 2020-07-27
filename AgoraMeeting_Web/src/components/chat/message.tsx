import React from 'react';
import './index.scss';
import { Link } from 'react-router-dom';
import { useRoomState } from '@/containers/root-container';
import { t } from '@/i18n';
import { confApi } from '@/services/meeting-api';
import { roomStore } from '@/stores/room';
interface MessageProps {
  nickname: string
  content: string
  link?: string
  sender?: boolean
  children?: any
  ref?: any
  className?: string
}

export const Message: React.FC<MessageProps> = ({
  nickname,
  content,
  link,
  sender,
  children,
  ref,
  className
}) => {
  return (
  <div ref={ref} className={`message ${sender ? 'sent': 'receive'} ${className ? className : ''}`}>
    <div className='content'>
      {!sender ? <div className='nickname'>{nickname}</div> : null}
      <div className='text'>
        {content}
      </div>
    </div>
    {children ? children : null}
  </div>
  )
}