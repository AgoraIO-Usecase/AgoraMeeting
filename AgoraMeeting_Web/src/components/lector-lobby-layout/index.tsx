import React, { useEffect, useRef } from 'react'
import styles from './index.module.scss'
import './layout.scss'
import { AgoraVideoPlayer } from '@/components/agora-video-player'
import { useLocation } from 'react-router-dom'
import { Board } from '@/components/board'
import { ShareScreen } from '@/components/share-screen'
import { useRoomState } from '@/containers/root-container'
import {useStreams} from '@/hooks/use-streams'

const ControlBtnGroup = (props: any) => {
  return (
    <div className={styles.controlBar}>
      <div className={styles.leftBtn} onClick={props.handleLeftBtnClick}>
        <span className={styles.leftArrow}></span>
      </div>
      <div className={styles.rightBtn} onClick={props.handleRightBtnClick}>
        <span className={styles.rightArrow}></span>
      </div>
    </div>
  )
}

const _LectorLobbyLayout = () => {

  const location = useLocation()

  const itemsRef = useRef<any>(null)

  const offsetXWidth = useRef<number>(0)

  const roomState = useRoomState()

  const muteAllAudio = roomState.confState.muteAllAudio

  // TODO: need remove
  //@ts-ignore
  window.bar = itemsRef

  useEffect(() => {
    return () => {
      itemsRef.current = null;
    }
  }, [])

  const offXLeft = (current: any, offsetX: number) => {
    current.scrollLeft -= offsetX
  }

  const offXRight = (current: any, offsetX: number) => {
    current.scrollLeft += offsetX
  }

  const handleLeftBtnClick = () => {
    if (itemsRef.current && offsetXWidth.current) {
      offXLeft(itemsRef.current, offsetXWidth.current)
    }
  }

  const handleRightBtnClick = () => {
    if (itemsRef.current && offsetXWidth.current) {
      offXRight(itemsRef.current, offsetXWidth.current)
    }
  }

  useEffect(() => {
    if (itemsRef.current) {
      offsetXWidth.current = itemsRef.current.clientWidth
    }

    window.addEventListener('resize', (evt: any) => {
      if (itemsRef.current) {
        offsetXWidth.current = itemsRef.current.clientWidth - 84
      }
    })

    return () => {
      window.removeEventListener('resize', (evt: any) => {
      })
    }
  }, [])

  const maximum = roomState.maximum

  const {largeStream, otherStreams} = useStreams(roomState)

  //@ts-ignore
  window.largeStream = largeStream

  //@ts-ignore
  window.otherStreams = otherStreams

  // //@ts-ignore
  // window.shareStream = shareStream

  return (
    <div className={styles.lectorLobbyLayout}>
      {otherStreams.count() > 0 ?
        <section className={styles.marqueeBar} style={{"display": (maximum ? 'none' : 'flex')}}>
          <ControlBtnGroup
            handleLeftBtnClick={handleLeftBtnClick}
            handleRightBtnClick={handleRightBtnClick}
          />
          <div ref={itemsRef} className={styles.itemContainer}>
            {otherStreams.map((stream: any, index: number) => 
              (
                <AgoraVideoPlayer
                  isBoardOwner={stream.isBoardOwner}
                  isHost={stream.isHost}
                  isMe={stream.isMe}
                  createBoardUserId={stream.createBoardUserId}
                  muteAllAudio={stream.muteAllAudio}
                  key={`${index}${stream.userId}`}
                  uid={stream.uid}
                  userId={stream.userId}
                  stream={stream.stream} 
                  video={stream.video}
                  audio={stream.audio}
                  chat={stream.chat}
                  grantBoard={stream.grantBoard}
                  grantScreen={stream.grantScreen}
                  name={stream.userName}
                  domId={`dom-normal-${stream.userId}`}
                  // name={`name-${index}`}
                />
              )
            )}
          </div>
        </section> 
      : null}
      <div className={styles.mainLectorView}>
        {Boolean(roomState.confState.shareBoard) ? 
          <Board /> : null}
        {Boolean(roomState.confState.shareScreen) ? 
          <ShareScreen shareStream={largeStream} /> : null}
        {!roomState.confState.shareScreen && largeStream !== null ? 
        <div className="screen">
          <AgoraVideoPlayer
            isBoardOwner={largeStream.isBoardOwner}
            isHost={largeStream.isHost}
            isMe={largeStream.isMe}
            createBoardUserId={largeStream.createBoardUserId}
            muteAllAudio={largeStream.muteAllAudio}
            resizable={true}
            key={`dom-large-${largeStream.uid}-${largeStream.screen ? 'screen-share' : 'large-view'}`}
            uid={largeStream.uid}
            userId={largeStream.userId}
            stream={largeStream.stream} 
            video={largeStream.video}
            audio={largeStream.audio}
            chat={largeStream.chat}
            grantBoard={largeStream.grantBoard}
            grantScreen={largeStream.grantScreen}
            name={largeStream.userName}
            screen={largeStream.screen}
            domId={`dom-large-${largeStream.uid}-${largeStream.screen ? 'screen-share' : 'large-view'}`}
            large={true} />
        </div> : null}
      </div>
    </div>
  )
}

export const LectorLobbyLayout = React.memo(_LectorLobbyLayout)