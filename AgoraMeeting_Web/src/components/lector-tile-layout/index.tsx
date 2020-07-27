import React, { useMemo } from 'react'
import styles from './index.module.scss'
import { AgoraVideoPlayer } from '@/components/agora-video-player'
import { useRoomState } from '@/containers/root-container'

const _LectorTileLayout = (props: any) => {  

  const muteAllAudio = useRoomState().confState.muteAllAudio

  const count: number = 16

  const items = Array(count).fill(0)

  const [GridsLayout, row, col] = useMemo(() => {
    if (count > 1 && count <= 2) return [styles.twoCell, 1, 2]
    if (count > 2 && count <= 4) return [styles.fourCell, 2, 2]
    if (count > 5 && count <= 9) return [styles.nineGrid, 3, 3]
    if (count > 9 && count <= 16) return[styles.sixTeenGrid, 4, 4]

    return [styles.oneCell, 1, 1]
  }, [count])

  return (
    <div className={styles.lectorTileLayout}>
      <div className={`${styles.gridWrapper} ${GridsLayout}`}
        style={
          {
            gridTemplateColumns: `repeat(${row}, ${col}fr)`,
            gridTemplateRows: `repeat(${row}, ${col}fr)`
          }
        }
      >
        {items.map((item: any, index: number) => (
          <div key={index} style={{
            // gridRow: 1
          }}>
            <AgoraVideoPlayer
              isHost={0}
              isMe={0}
              createBoardUserId={'0'}
              muteAllAudio={muteAllAudio}
              key={index}
              uid={0}
              userId={'demo'}
              stream={index % 2} 
              video={index % 2}
              audio={index % 2} 
              chat={index % 2}
              grantBoard={index % 2}
              grantScreen={index % 2}
              name={`name-${index}`}
              domId={`dom-tile-${index%2}`}
            />
          </div>
        ))}
      </div>
    </div>
  )
}

export const LectorTileLayout = React.memo(_LectorTileLayout)
