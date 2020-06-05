import React, {useState, useRef, useEffect} from 'react'
import { TextField } from '@material-ui/core'
import '../index.scss'
import { Message } from '@/components/chat/message'
import { ChatMessage } from '@/utils/types'
import { useRoomState } from '@/containers/root-container'
import { useChat } from '@/hooks/use-chat'
import { t } from '@/i18n'

const regexPattern = /^\s+/;

const truncateBlank: (m: string) => string = (message: string) => message.replace(regexPattern, '');

export const ChatDrawerBox = (props: any) => {

  const [text, setText] = useState<string>('');

  const roomState = useRoomState()

  const { role, messages, value, sendMessage, handleChange, } = useChat()

  const ref = useRef(null);

  const scrollDown = (current: any) => {
    current.scrollTop = current.scrollHeight;
  }

  useEffect(() => {
    scrollDown(ref.current);
  }, [messages]);

  return (
    <div className='drawer-box'>
      <div className='drawer-header'>
        <span>{props.title ? props.title : ''}</span>
        <span className='close' onClick={props.onClose}></span>
      </div>
      <div className='drawer-body'>
        <div className='scrollable-container'>
          <div className='chat-messages' ref={ref}>
          {roomState.messages.map((item: ChatMessage, key: number) => (
            <Message
              key={key}
              nickname={item.userName}
              content={item.text}
              link={item.link}
              sender={item.sender}
            />
          ))}
          </div>
        </div>
      </div>
      <div className='chat-message'>
        <textarea className='custom-textarea'
          rows={4}
          value={value}
          onChange={handleChange}
          onKeyPress={async (evt: any) => {
            if (!evt.shiftKey && evt.key === 'Enter') {
              const val = truncateBlank(value)
              val.length > 0 && await sendMessage(val);
            }
          }}
          // onKeyDownCapture={async (evt: any) => {
          //   if (evt.key === 'Enter') {
          //     const val = truncateBlank(value)
          //     val.length > 0 && await sendMessage(val);
          //   }
          // }}
        >
        </textarea>
        {/* <TextField
          variant='outlined'
          multiline
          className='custom-textarea'
          rows={4}
          value={value}
          onChange={handleChange}
          onKeyPress={async (evt: any) => {
            if (!evt.shiftKey && evt.key === 'Enter') {
              const val = truncateBlank(value)
              val.length > 0 && await sendMessage(val);
            }
          }}

        /> */}
        <a onClick={async () => {
          const val = truncateBlank(value)
          await sendMessage(val)
        }} className='send-btn'>
          {t('meeting.chat.send')}
        </a>
      </div>
    </div> 
  )
}