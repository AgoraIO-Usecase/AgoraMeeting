import React, {useState, useMemo, useEffect, useCallback} from 'react'
import './index.scss'
import { MediaDropDownMenu } from '@/components/dropdown-menu'
import { roomStore } from '@/stores/room'

const ResizeBar = (props: any) => (
  <div className='board-nav-bar' onClick={props.onBoardNav}>
    {/* <div className='icon sharing' id='applySharing'></div> */}
    <div className='icon resize' id='resize' data-share={"maximum"} ></div>
  </div>
)

export interface ItemProps {
  uid: number
  userId: string
  name: string
  video: number
  audio: number
  chat: number
  grantBoard: number
  grantScreen: number
  stream: any
  role?: number
  local?: boolean
  screen?: boolean
  shareBoard?: number
  large?: boolean,
  autoplay?: boolean,
  domId: string,
  resizable?: boolean
  isHost: number
  isMe: number
  createBoardUserId: string
  muteAllAudio: number
  isBoardOwner?: number
}

const _VideoPlayer: React.FC<ItemProps> = ({
  uid,
  userId,
  name,
  video,
  audio,
  chat,
  grantBoard,
  grantScreen,
  shareBoard,
  stream,
  role,
  local,
  screen,
  large,
  autoplay,
  domId,
  isHost,
  isMe,
  createBoardUserId,
  muteAllAudio,
  resizable,
  isBoardOwner
}) => {

  // const myAudioState = !!roomStore.state.me.audio
  // const myVideoState = !!roomStore.state.me.video

  // const autoplay = myAudioState || myVideoState

  const [resume, setResume] = useState<boolean>(false);

  const VideoText = useCallback(() => {
    return (
      screen ? 
        <>
          <span className="screen-title">
            {name}
          </span>
          <span className="screen-share">
            {'的屏幕共享'}
          </span>
        </> : 
        <>
          {/* <span className="screen-title"> */}
            {name}
          {/* </span> */}
        </>
    )
  }, [screen, name])

  const needResume = useMemo(() => {
    return resume === true &&
      // autoplay === false &&
      local === false
  }, [resume, autoplay, local])

  const domPlayer = useCallback((element: any) => {
    if (element && stream) {
      stream.isPlaying() && stream.stop()
      stream.play(`${element.id}`, { fit: screen ? 'contain' : 'cover'}, (err: any) => {
        console.log('play status', err)
        if (err && err.audio && err.audio.status !== 'aborted' && !local) {
          stream.isPaused() && setResume(true);
          console.warn('[video-player] play failed ', JSON.stringify(err), uid, stream.isPaused(), stream.isPlaying());
        }
      })
    }
  }, [stream, screen, setResume])

  useEffect(() => {
    if (!stream) return
    if (video) {
      console.log('stream unmute video');
      stream.unmuteVideo();
    } else {
      console.log('stream mute video');
      stream.muteVideo();
    }

  }, [stream, video])

  useEffect(() => {
    if (!stream) return
    if (audio) {
      console.log('stream unmute audio');
      stream.unmuteAudio();
    } else {
      console.log('stream mute audio');
      stream.muteAudio();
    }

  }, [stream, audio])

  return (
    <div className={`marqueeItemBox ${large ? 'largeView' : ''}`}>
      {/* {resizable ? <ResizeBar onClick={(evt: any) => {
        roomStore.toggleMaximum()
      }} /> : null} */}
      <div className='marqueeItem'>
        {stream ? 
          <>
            <div id={domId} ref={domPlayer} className='agoraVideoPlayer'>
            {
              large ?
              <span className={'large-title'}>
                <VideoText />
                {/* {text ? text : ''} */}
              </span> : null
            }
            </div>
            {needResume ? <div className='clickable' onClick={() => {
              stream.resume().then(() => {
                setResume(false)
              }).catch(console.warn)
            }}></div> : null} 
          </>
           : 
          <div className='previewCover'>
            <VideoText />
            {/* {text ? text : ''} */}
          </div>
        }
        {large !== true ? <div className='mediaBtnGroup'>
          {role ?
            <i className='roleHost'></i>
            :
            null
          }
          {shareBoard ?
            <i className={'shareBoard'}></i>
            :
            null
          }
          <i className={audio ? 'unmuteAudio' : 'muteAudio'}></i>
          {stream ? 
            <span className={'title'}>
              {name ? name : ''}
            </span> :
            null}
        </div> : null}
      </div>
      {!screen ? 
      <div className={`mediaDropdown`}>
        <MediaDropDownMenu
          isHost={isHost}
          isMe={isMe}
          isBoardOwner={isBoardOwner as number}
          createBoardUserId={createBoardUserId}
          muteAllAudio={muteAllAudio}
          video={video}
          audio={audio}
          chat={chat}
          grantBoard={grantBoard}
          role={role}
          userId={userId}
          uid={uid} />
      </div> : null }
    </div>
  )
}

export const AgoraVideoPlayer = React.memo(_VideoPlayer)