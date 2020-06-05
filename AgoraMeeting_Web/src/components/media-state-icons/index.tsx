import React from 'react'
import './index.scss'

export const MediaStateIcon = (props: any) => {
  return (
    <i className={`${props.className}`}
      onClick={props.onClick}></i>
  )
}