import React from 'react'
import { Select, MenuItem } from '@material-ui/core'

export interface CustomSelectProps {
  text: string
}

export const DeviceSelect: React.FC<any> = ({
  value,
  onChange,
  items,
  className
}) => {
  return (
    <Select
      className={className}
      value={value}
      onChange={onChange}
    >
      {items.map((item: any, key: number) => 
        <MenuItem key={key} value={key}>{item.text}</MenuItem>
      )}
    </Select>
  )
}