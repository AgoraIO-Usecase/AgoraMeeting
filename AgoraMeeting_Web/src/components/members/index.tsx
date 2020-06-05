import React from 'react'
import './index.scss'

export interface MemberListProps {
  members: any[]
}

export const Members: React.FC<MemberListProps> = (props) => {
  return (
    <div className='agora-drawer'>
      <div className='drawer-header'>
        <span className='drawer-header-title'>成员(37)</span>
        <span className='close'></span>
      </div>
      <div className='drawer-body'>
        {props.members && props.members.map((member: any, index: number) => (
          {
            name: member.name,
            video: member.video,
            audio: member.audio,
            role: member.role,
          }
        ))}
      </div>
    </div>
  )
}