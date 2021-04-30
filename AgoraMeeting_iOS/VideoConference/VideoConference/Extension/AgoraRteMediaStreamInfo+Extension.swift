//
//  AgoraRteMediaStreamInfo+Extension.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/14.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte

extension AgoraRteMediaStreamInfo {
    var meetingInfo: MeetingVM.Info {
        let userId = owner.userId
        let userRole = owner.userRole
        let userName = owner.userName
        
        let user = MeetingVM.Info.User(userId: userId, userName: userName, userRole: userRole)
        if streamName == "ScreenShare" {
            let screenInfo = MeetingVM.Info.ShareScreenInfo(streamId: streamId)
            return MeetingVM.Info(type: .screen, user: user, screenInfo: screenInfo)
        }
        let avInfo = MeetingVM.Info.AVInfo(streamId: streamId, streamType: streamType)
        return MeetingVM.Info(type: .av, user: user, avInfo: avInfo)
    }
}
