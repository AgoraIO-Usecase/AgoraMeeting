import React, {useEffect, useRef, useCallback, useState, useMemo} from 'react';
import { Room } from 'white-web-sdk';
import { whiteboard } from '@/stores/whiteboard';
import { t } from '@/i18n';
import { Progress } from '@/components/progress/progress';
import './index.scss'
import 'white-web-sdk/style/index.css';
import { useRoomState, useWhiteboardState } from '@/containers/root-container';
import ScaleController from '@/modules/whiteboard/scale-controller';
import { SketchPicker, RGBColor } from 'react-color';
import { roomStore } from '@/stores/room';
import { globalStore } from '@/stores/global';
import { get } from 'lodash';

const pathName = (path: string): string => {
  const reg = /\/([^/]*)\//g;
  reg.exec(path);
  if (RegExp.$1 === 'aria') {
      return '';
  } else {
      return RegExp.$1;
  }
}

const BoardMenuItem = (props: any) => (
  <i className={`${props.name} ${props.active ? 'active': ''}`} id={props.name} />
)

const tools = [
  {
    name: 'selector'
  },
  {
    name: 'pencil'
  },
  {
    name: 'rectangle',
  },
  {
    name: 'ellipse'
  },
  {
    name: 'text'
  },
  {
    name: 'eraser'
  },
  {
    name: 'color_picker'
  },
  {
    name: 'add'
  },
  // {
  //   name: 'upload'
  // },
  {
    name: 'hand_tool'
  }
];

const items = tools

const BoardNavBar = (props: any) => (
  <div className='board-nav-bar' onClick={props.onBoardNav}>
    {/* {!props.isOwner ? <div className='icon sharing' id='applySharing'></div> : null} */}
    {props.isOwner ? <div className='end-share' id='end-share' data-share={"share-btn"}>
      <div className='icon end-share-btn' data-share={"share-btn"}></div>
      <span className='title' data-share={"share-btn"} >{t('meeting.stop_sharing')}</span>
    </div> : null }
    {!props.isOwner && !props.isHost ? <div className='icon applyBoard' id='applyBoard'>{props.grantBoard ? t('meeting.board.cancel') : t('meeting.board.apply')}</div> : null}
    <div className={`icon ${roomStore.state.maximum ? 'minimum' : 'maximum'}`} id='resize' data-share={"maximum"} ></div>
  </div>
)

const BoardMenu = (props: any) => (
  <div className='menu' onClick={props.onMenu}>
    {items
    .filter(
      (item: any) => 
        props.excludeTools.indexOf(item.name) === -1)
      .map((item: any, idx: number) => (
      <BoardMenuItem name={item.name} active={props.active === item.name} key={idx} />
    ))}
  </div>
)

const Pagination = ({
  children,
  onPagination,
  currentPage,
  totalPage
}: any) => (
  <div className='pagination' onClick={onPagination}>
    {children}
    <i className='first_page' id='first_page'></i>
    <i className='prev_page' id='prev_page'></i>
    <div className='current_page'>
      <span>{currentPage+1}/{totalPage}</span>
    </div>
    <i className='next_page' id='next_page'></i>
    <i className='last_page' id='last_page'></i>
  </div>
)

const NetlessBoard: React.FC<any> = ({
  loading,
}) => {

  const roomState = useRoomState()

  const me = roomState.me

  const isHost = me.role === 1

  const isOwner = me.userId === roomState.confState.createBoardUserId

  const boardState = useWhiteboardState()

  const room = boardState.room

  const isWritable = useMemo(() => {
    return me.role === 1 || Boolean(me.grantBoard)
  }, [me.role, me.grantBoard])

  useEffect(() => {
    console.log("create board", isWritable, roomState.confState.boardId, roomState.confState.boardToken, isWritable)
    whiteboard.join({
      uuid: roomState.confState.boardId,
      roomToken: roomState.confState.boardToken,
      isWritable: isWritable,
      userPayload: {
        identity: isWritable ? 'host' : 'guest',
        userId: roomStore.state.me.userId,
      }
    })

    return () => {
      console.log("leave create board", isWritable, roomState.confState.boardId, roomState.confState.boardToken, isWritable)
      // if (whiteboard.state.room) {
      //   whiteboard.state.room.bindHtmlElement(null)
      // }
      whiteboard.leave()
    }
  }, [isWritable])

  useEffect(() => {
    if (!room) return 
    if (isOwner) {
      whiteboard.setBroadCaster()
    } else {
      whiteboard.setFollower()
    }

    if (me.role === 1 || me.grantBoard || isOwner) {
      whiteboard.setWritable(true)
      return
    }
    else if (me.grantBoard === 0) {
      whiteboard.setWritable(false)
      return
    }
  }, [room, me.role, me.grantBoard, isOwner])

  useEffect(() => {
    if (!room || whiteboard.leaving === true) return
    whiteboard.updateRoomState()
    window.addEventListener('resize', (evt: any) => {
      if (whiteboard.state.room !== null && whiteboard.state.room.isWritable && whiteboard.leaving !== true) {
        whiteboard.state.room.moveCamera({centerX: 0, centerY: 0})
        whiteboard.state.room.refreshViewSize()    
      }
    })
    return () => {
      // if (whiteboard.state.room) {
      //   whiteboard.state.room.bindHtmlElement(null)
      // }
      window.removeEventListener('resize', (evt: any) => {})
    }
  }, [room])

  useEffect(() => {
    if (!room || whiteboard.leaving === true) return
    room.moveCamera({centerX: 0, centerY: 0})
    room.refreshViewSize()
  }, [room, roomState.meetingState, roomState.maximum])

  // useEffect(() => {
  //   console.log("roomState ", roomState.maximum)
  //   if (room && whiteboard.leaving !== true) {
  //     room.moveCamera({centerX: 0, centerY: 0})
  //     room.refreshViewSize()
  //   }
  // }, [room, roomState.maximum])

  const [activeItem, setActiveItem] = useState<string>('')
  const [activePageItem, setActivePageItem] = useState<string>('')

  const bindBoard = useCallback((element: any) => {
    if (whiteboard.leaving) return
    if (!element && room) {
      room.bindHtmlElement(null)
    }
    if (element && room) {
      room.bindHtmlElement(element)
    }
  }, [room])

  const onMenu = useCallback((evt: any) => {
    if (!room || (room && !room.isWritable) || whiteboard.leaving === true) return
  
    if (evt.target.id !== 'hand_tool' && room.handToolActive) {
      room.handToolActive = false
    }
    
    switch (evt.target.id) {
      case 'eraser':
      case 'ellipse':
      case 'rectangle':
      case 'pencil':
      case 'text':
      case 'selector': {
        room.setMemberState({
          currentApplianceName: evt.target.id
        })
        setActiveItem(evt.target.id)
        return 
      }
      case 'color_picker': {
        activeItem !== 'color_picker' ? setActiveItem(evt.target.id) : setActiveItem('')
        return
      }
      case 'add': {
        const newIndex = room.state.sceneState.index + 1
        const scenePath = room.state.sceneState.scenePath
        const currentPath = `/${pathName(scenePath)}`
        if (room.isWritable) {
          room.putScenes(currentPath, [{}], newIndex)
          room.setSceneIndex(newIndex)
        }

        whiteboard.updateRoomState()
        return
      }
      case 'hand_tool': {
        const inactive = activeItem !== 'hand_tool' ? true : false
        setActiveItem(inactive ? evt.target.id : '')
        room.handToolActive = inactive ? true : false
        return 
      }
    }
  }, [activeItem, room, setActiveItem])

  const onPagination = useCallback((evt: any) => {
    if (!room || (room && !room.isWritable) || whiteboard.leaving === true) return

    const changePage = (idx: number, force?: boolean) => {
      if (!boardState || !room || !room.isWritable || whiteboard.leaving === true) return;
        const _idx = idx;
        console.log(_idx, force, boardState.currentPage, boardState.totalPage)

        if (_idx < 0 || _idx >= boardState.totalPage) {
          console.warn(_idx < 0, _idx >= boardState.totalPage)
          return
        }
        if (force) {
          room.setSceneIndex(_idx);
          whiteboard.updateRoomState();
          return
        }
        if (boardState.type === 'dynamic') {
          if (_idx > boardState.currentPage) {
            room.pptNextStep();
          } else {
            room.pptPreviousStep();
          }
        } else {
          room.setSceneIndex(_idx);
        }
        whiteboard.updateRoomState();
    }
  
    switch (evt.target.id) {
      case 'first_page': {
        changePage(0, true)
        return
      }
      case 'last_page': {
        changePage(boardState.totalPage-1, true)
        return
      }
      case 'next_page': {
        changePage(boardState.currentPage + 1)
        return
      }
      case 'prev_page' : {
        changePage(boardState.currentPage - 1)
        return
      }
    }
  }, [
      room,
      boardState.type,
      boardState.currentPage,
      boardState.totalPage,
      setActivePageItem
  ])

  const onBoardNav = async (evt: any) => {
    evt.persist()
    evt.preventDefault()
    const type = get(evt, 'target.dataset.share')

    if (type === 'maximum') {
      roomStore.toggleMaximum()
    }

    if (type === 'share-btn') {
      try {
        globalStore.showLoading()
        await roomStore.updateShareState('shareBoard', false)
        await whiteboard.endShare()
      } catch(err) {
        throw err
      } finally {
        globalStore.stopLoading()
      }
    }

    if (evt && evt.target && evt.target.id === 'applyBoard') {
      const grantBoard = roomStore.state.me.grantBoard
      if (!grantBoard) {
        await roomStore.applyBoard()
      } else {
        await roomStore.cancelBoard(roomStore.state.me.userId)
      }
    }
  }

  let strokeColor: RGBColor | undefined = undefined;

  if (boardState.room && boardState.room.state.memberState.strokeColor) {
    const color = boardState.room.state.memberState.strokeColor;
    strokeColor = {
      r: color[0],
      g: color[1],
      b: color[2],
    }
  }

  const onColorChanged = useCallback((color: any) => {
    if (!room || (room && !room.isWritable) || whiteboard.leaving === true) return;
    const {rgb} = color;
    const {r, g, b} = rgb;
    room.setMemberState({
      strokeColor: [r, g, b]
    });
  }, [room])

  return (
    <div className={`board ${activeItem === 'hand_tool' ? 'show_hand_tool' : ''}` }>
      { loading || !room ? <Progress title={t('whiteboard.loading')}></Progress> : null}
      <div ref={bindBoard} id='board' className='view' onClick={(evt: any) => {
        if (evt.target.id !== 'color_picker' && activeItem === 'color_picker') {
          setActiveItem('')
          evt.stopPropagation()
        }
      }}></div>
      <BoardMenu
        excludeTools={isOwner ? [''] : ['add']}
        active={activeItem}
        onMenu={onMenu}
      />
      {
        activeItem === 'color_picker' && strokeColor ?
          <div className="demo_color_picker">
            <SketchPicker
              color={strokeColor}
              onChangeComplete={onColorChanged} />
          </div>
          : null
      }
      {isOwner ?
      <Pagination
        active={activePageItem}
        currentPage={boardState.currentPage}
        totalPage={boardState.totalPage}
        onPagination={onPagination}
      >
        {
          room ? <ScaleController
            zoomScale={boardState.scale}
            zoomChange={(scale: number) => {
              room.moveCamera({scale});
              whiteboard.updateScale(scale);
            }}
          /> : null
        }
      </Pagination> : null}
      <BoardNavBar
        isHost={isHost}
        isOwner={isOwner}
        onBoardNav={onBoardNav}
        grantBoard={me.grantBoard}
      />
    </div>
  )
}

export const Board = React.memo(NetlessBoard)