import React from 'react'
import { t } from '@/i18n'
import { roomStore } from '@/stores/room'
import { AgoraVideoPlayer } from '@/components/agora-video-player'
import './index.scss'
import { globalStore } from '@/stores/global'
import { get } from 'lodash'

const BoardNavBar = (props: any) => (
  <div className='board-nav-bar' onClick={props.onBoardNav}>
    {/* <div className='icon sharing' id='applySharing'></div> */}
    {roomStore.state.me.grantScreen ? <div className='end-share' data-share={"share-screen"}>
      <div className='icon end-share-btn' data-share={"share-screen"}></div>
      <span className='title' data-share={"share-screen"}>{t('meeting.stop_sharing')}</span>
    </div> : null}
    <div className={`icon ${roomStore.state.maximum ? 'minimum' : 'maximum'}`} id='resize' data-share={"maximum"} ></div>
  </div>
)

export const ShareScreen: React.FC<any> = (props) => {
  const {shareStream} = props

  const onBoardNav = async (evt: any) => {
    evt.persist()
    evt.preventDefault()
    const type = get(evt, 'target.dataset.share')

    if (type === 'maximum') {
      roomStore.toggleMaximum()
    }

    if (type === 'share-screen') {
      try {
        globalStore.showLoading()
        await roomStore.stopWebScreenShare()
        await roomStore.updateShareState('shareScreen', false)
        // await whiteboard.endShare()
      } catch(err) {
        throw err
      } finally {
        globalStore.stopLoading()
      }
    }

  }

  return (
    <div className="screen">
      <BoardNavBar onBoardNav={onBoardNav} />
      {shareStream ? <AgoraVideoPlayer 
          isHost={shareStream.isHost}
          isBoardOwner={shareStream.isBoardOwner}
          isMe={shareStream.isMe}
          createBoardUserId={'0'}
          muteAllAudio={0}
          screen={true}
          uid={shareStream.uid}
          userId={shareStream.userId}
          stream={shareStream.stream} 
          video={shareStream.video}
          audio={shareStream.audio} 
          chat={shareStream.chat}
          grantBoard={shareStream.grantBoard}
          grantScreen={shareStream.grantScreen}
          name={shareStream.userName}
          large={true}
          domId={`dom-large-${shareStream.userId}`}
        /> : null}
        
    </div>
  )
}