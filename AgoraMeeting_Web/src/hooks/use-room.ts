import { useMemo } from 'react';
import { useRoomState } from '@/containers/root-container'
import { transformMediaState } from '@/utils/helper';

export const useRoom = () => {
  const roomState = useRoomState()

  const members = useMemo(() => {
    const hash: {[userId: string]: any} = {}

    const hosts = roomState.users.hosts.toArray().map((res: any) => res[1])
    const members = roomState.users.audiences.toArray().map((res: any) => res[1])

    const muteAllAudio = roomState.confState.muteAllAudio

    const createBoardUserId = roomState.confState.createBoardUserId

    const myRole = roomState.me.role

    const myUserId = roomState.me.userId

    const shareBoardUsers = roomState.users.shareBoardUsers

    const shareScreenUsers = roomState.users.shareScreenUsers

    const amHost = myRole === 1

    return [roomState.me]
      .concat(hosts)
      .concat(members)
      .reduce((vector: any, next) => {
        if (!hash[next.userId]) {
          const mediaState = transformMediaState(
            roomState.me,
            next,
            roomState.users,
            roomState.confState
          )
          const rawNext = {
            ...next,
            ...mediaState
          }
          vector.push(rawNext)
          hash[next.userId] = true
        }
        return vector;
      }, [])
  }, [
    roomState.me,
    roomState.users.hosts, 
    roomState.users.audiences,
    roomState.confState.muteAllAudio,
    roomState.confState.createBoardUserId,
    roomState.users.shareBoardUsers,
    roomState.users.shareScreenUsers,
    roomState.confState.shareBoard,
    roomState.confState.shareScreen,
  ])

  return {
    members,
    roomState
  }
}