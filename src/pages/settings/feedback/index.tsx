import React, { useState } from 'react'
import { TextField, Box } from '@material-ui/core'
import './feedback.scss'
import CustomButton from '@/components/custom-button'
import { DeviceSelect as CustomSelect } from '@/components/meeting-select'
import { t } from '@/i18n'
import Log from '@/utils/LogUploader'
import { globalStore } from '@/stores/global'

const feedTypes = [
  {
    text: '问题-1',
  },
  {
    text: '问题-2',
  },
]

export const FeedBackPage = () => {

  const [typeIdx, setTypeIdx] = useState<number>(0)

  const onChange = (evt: any) => {
    setTypeIdx(evt.target.value)
  }

  const uploadLog = () => {
    globalStore.showLoading()
    Log.doUpload().then((resultCode: any) => {
      globalStore.showDialog({
        type: 'uploadLog',
        message: t('toast.show_log_id', { reason: `${resultCode}` }),
        confirmText: '确定',
        showConfirm: true,
        showCancel: false
      });
    }).finally(() => {
      globalStore.stopLoading()
    })
  }

  return (
    <div className='partial-page feedback'>
      {/* <div className='item-label'>
        {t('feedback.issue.type')}
      </div>
      <div className='item'>
        <CustomSelect
          onChange={onChange}
          value={typeIdx}
          className='video-devices-select'
          items={feedTypes}
        />
      </div>
      <div className='item-label'>
        {t('feedback.issue.description')}
      </div>
      <div className='item'>
        <TextField
          variant='outlined'
          multiline
          className='custom-textarea'
          rows={4}
        />
      </div> */}
      <div className='item'>
        <CustomButton onClick={uploadLog} disableElevation={true} className='upload-btn' name='上传日志'></CustomButton>
        <h6>遇到问题，上传日志</h6>
      </div>
    </div>
  )
}