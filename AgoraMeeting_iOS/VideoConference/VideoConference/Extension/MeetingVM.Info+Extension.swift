//
//  MeetingVM.Info.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/14.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

extension MeetingVM.Info {
    var videoCellModel: VideoCellModel {
        let m = VideoCellModel()
        m.enableAudio = hasAudio
        m.enableVideo = hasVideo
        m.shareBoard = type == .board
        m.shareScreen = type == .screen
        m.role = self.user.userRole == "host" ? 1 : 0
        m.userName = user.userName
        m.userId = user.userId
        m.isMe = isMe
        m.headImageName = headImageName
        return m
    }
    
    func videoCellModel1(roomHasHost: Bool) -> VideoCell.Info {
        let showMeunButton = self.type == .av
        let name = user.userName
        
        var sheetInfos = [VideoCellSheetView.Info]()
        if isMe, isHost {
            let info = VideoCellSheetView.Info(actionType: .abandonHost)
            sheetInfos.append(info)
            
        }
        if isMe, !isHost{
            if !roomHasHost  {
                let info = VideoCellSheetView.Info(actionType: .becomeHost)
                sheetInfos.append(info)
            }
        }
        if !isMe, localUserIsHost {
            
            let info1 = VideoCellSheetView.Info(actionType: .closeAudio)
            let info2 = VideoCellSheetView.Info(actionType: .closeVideo)
            let info3 = VideoCellSheetView.Info(actionType: .setAsHost)
            let info4 = VideoCellSheetView.Info(actionType: .remove)
            
            hasAudio ? sheetInfos += [info1] : nil
            hasVideo ? sheetInfos += [info2] : nil
            
            sheetInfos += [info3, info4]
        }
        
        
        
        return VideoCell.Info(isHost: isHost,
                               enableAudio: hasAudio,
                               name: name,
                               isUp: getUpType == .up,
                               showMeunButton: showMeunButton,
                               headImageName: headImageName,
                               showHeadImage: !hasVideo,
                               isMe: isMe,
                               streamId: streamId,
                               sheetInfos: sheetInfos,
                               userId: user.userId)
    }
    
}
