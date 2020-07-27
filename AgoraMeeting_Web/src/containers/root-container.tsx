import React, { useEffect, useRef, useMemo } from 'react'
import {historyStore} from '@/stores/history'
import { GlobalState, globalStore} from '@/stores/global'
import { RoomState, roomStore} from '@/stores/room'
import { WhiteboardState, whiteboard } from '@/stores/whiteboard'
import { useHistory, useLocation } from 'react-router-dom'
import { resolvePeerMessage, jsonParse } from '@/utils/helper'
import GlobalStorage from '@/utils/custom-storage'
import {fetchI18n} from '@/services/meeting-api'
import { t } from '@/i18n'
import { ChatCmdType, ProtocolVersion } from '@/utils/agora-rtm-client'
import Log from '@/utils/LogUploader'
import { RoomKeyIdentifier, SessionKeyIdentifier, userKeyIdentifier } from '@/utils/config'
import { useRtm } from '@/hooks/use-rtm'

export type IRootProvider = {
  globalState: GlobalState
  roomState: RoomState
  whiteboardState: WhiteboardState
  historyState: any
}

export interface IObserver<T> {
  subscribe: (setState: (state: T) => void) => void
  unsubscribe: () => void
  defaultState: T
}

function useObserver<T>(store: IObserver<T>) {
  const [state, setState] = React.useState<T>(store.defaultState)
  React.useEffect(() => {
    store.subscribe((state: any) => {
      setState(state)
    })
    return () => {
      store.unsubscribe()
    }
  }, [])

  return state
}


export const RootContext = React.createContext({} as IRootProvider)

export const useStore = () => {
  const context = React.useContext(RootContext)
  if (context === undefined) {
    throw new Error('useStore must be used within a RootProvider')
  }
  return context
}

export const useGlobalState = () => {
  return useStore().globalState
}

export const useRoomState = () => {
  return useStore().roomState
}

export const useWhiteboardState = () => {
  return useStore().whiteboardState
}

const initLogWorker = () => {
  Log.init()
}

export const RootProvider: React.FC<any> = ({children}) => {
  const globalState = useObserver<GlobalState>(globalStore)
  const roomState = useObserver<RoomState>(roomStore)
  const whiteboardState = useObserver<WhiteboardState>(whiteboard)
  const historyState = useObserver<any>(historyStore)
  const history = useHistory()

  const ref = useRef<boolean>(false)

  useEffect(() => {
    return () => {
      ref.current = true
    }
  }, [])

  const value = {
    globalState,
    roomState,
    whiteboardState,
    historyState,
  }

  useEffect(() => {
    initLogWorker()
    fetchI18n()
    historyStore.setHistory(history)
  }, [])

  useMemo(() => {
    if (roomState.confState.muteAllAudio === 2) {
      globalStore.showToast({
        type: 'muteAudio',
        message: t('meeting.mute_audio'),
      })
    } else if (roomState.confState.muteAllAudio === 0) {
      globalStore.showToast({
        type: 'unmuteAudio',
        message: t('meeting.unmute_audio'),
      })
    }
  }, [roomState.confState.muteAllAudio])

  useRtm()

  const location = useLocation()

  useEffect(() => {
    const room = value.roomState
    GlobalStorage.save(RoomKeyIdentifier, {
      me: room.me,
      confState: {
        ...room.confState,
      },
    })
    GlobalStorage.save(userKeyIdentifier, {
      roomName: room.sessionInfo.roomName,
    })
    
    GlobalStorage.saveLocalStorage(userKeyIdentifier, {
      userName: room.sessionInfo.userName,
    })
    GlobalStorage.saveLocalStorage(SessionKeyIdentifier, {
      mediaState: {
        useCamera: room.mediaState.useCamera,
        useMicrophone: room.mediaState.useMicrophone,
      },
      mediaDevice: {
        cameraIdx: room.mediaDevice.cameraIdx,
        microphoneIdx: room.mediaDevice.microphoneIdx,
      }
    })
    GlobalStorage.setLanguage(value.globalState.language)
    // TODO: Please remove it before release in production
    // 备注：请在正式发布时删除操作的window属性
    //@ts-ignore
    window.room = roomState
    //@ts-ignore
    window.globalState = globalState
    //@ts-ignore
    window.whiteboard = whiteboardState
  }, [value, location])
  return (
    <RootContext.Provider value={value}>
      {children}
    </RootContext.Provider>
  )
}