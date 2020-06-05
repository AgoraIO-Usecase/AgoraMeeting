import React, {useMemo} from 'react'
import {t} from '@/i18n'

import './index.scss'

export const DropDownBtn = ({
  value,
  text,
  onClick,
  disable,
  needApply
}: any) => {

  const content = useMemo(() => {
    return needApply ? 
      t(`meeting.ctrl.apply.${text}`)
      :
      t(`meeting.ctrl.${value ? 'mute' : 'unmute'}.${text}`)
  }, 
  [t, text, value, needApply])

  return (
    <div className={`dropDownBtn ${value ? 'mute' : 'unmute'} ${disable ? 'disable' : ''}`} onClick={onClick}>
      {content}
    </div>
  )
}