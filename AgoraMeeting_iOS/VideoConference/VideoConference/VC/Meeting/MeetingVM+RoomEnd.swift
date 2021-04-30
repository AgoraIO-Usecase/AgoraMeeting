//
//  MeetingVM+RoomEnd.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/12.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte

extension MeetingVM {
    
    func handleRoomEndChange(scene: AgoraRteScene, cause: String?) {
        if endRoomFromMe { return }
        guard let causeString = cause else {
            return
        }
        do {
            let cause = try Cause.decode(jsonString: causeString)
            if let cmd = cause.getCmd, cmd == .endRoom {
                invokeMeetingVMDidEndRoom()
            }

        } catch let e {
            Log.error(error: e)
        }
    }
    
    
    
}
