//
//  MeetingVM+DataOp.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/9.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte
import AgoraRoom

extension MeetingVM {
    func addLocalUserInfo() {
        let localUserInfo = localUser.info
        Log.debug(text: "addLocalUserInfo 1", tag: "fetchInfos")
        guard !infos.hasContainLocalUser(userId: localUserInfo.userId, type: .av) else {
            return
        }
        Log.debug(text: "addLocalUserInfo 2", tag: "fetchInfos")
        let user = Info.User(userId: localUserInfo.userId,
                             userName: localUserInfo.userName,
                             userRole: localUserInfo.userRole)
        let info = MeetingVM.Info(type: .av, user: user, avInfo: .empty)
        infos.append(info)
    }
    
    func updateLocalUserInfo(event: AgoraRteUserEvent) {
        let localInfo = event.modifiedUser
        let streamId = localInfo.streamId
        let userId = localInfo.userId
        let userName = localInfo.userName
        let userRole = localInfo.userRole
        Log.info(text: "updateLocalUserInfo")
        if let oldLocalUserInfo = infos.filter({ $0.user.userId == userId && $0.type == .av }).first,
           let index = infos.firstIndex(of: oldLocalUserInfo) {
            let user = Info.User(userId: userId, userName: userName, userRole: userRole)
            let avInfo = Info.AVInfo(streamId: streamId, streamType: oldLocalUserInfo.avInfo.streamType)
            let info = MeetingVM.Info(type: .av, user: user, avInfo: avInfo)
            infos[index] = info
            return
        }
        
        Log.errorText(text: "updateLocalUserInfo not find local user in infos")
    }
    
    func updateLocalUserProperties(changedProperties: [String]) {
        if changedProperties.contains("dirty") {
            ARConferenceManager.getScene().leave()
            invokeMeetingVMShouldKickout()
            addBeKickoutNoti()
        }
    }
    
    func addLocalStream(event: AgoraRteMediaStreamEvent) {
        guard event.modifiedStream.streamName != "ScreenShare" else {
            return
        }
        let info = event.modifiedStream.meetingInfo
        let count = infos.count
        for i in 0..<count {
            if infos[i].user.userId == info.user.userId, infos[i].type == .av {
                infos[i].avInfo.setStreamType(streamType: info.avInfo.streamType)
                infos[i].avInfo.setStreamId(id: info.avInfo.streamId)
                break
            }
        }
    }
    
    func updateLocalStream(event: AgoraRteMediaStreamEvent) {
        guard event.modifiedStream.streamName != "ScreenShare" else {
            return
        }
        let streamType = event.modifiedStream.streamType
        updateBottomItem(streamType: streamType)
        let userId = localUser.info.userId
        for i in 0..<infos.count {
            if infos[i].user.userId == userId, infos[i].type == .av {
                infos[i].avInfo.setStreamType(streamType: streamType)
                break
            }
        }
    }
    
    private func updateLocalStream(streamType: AgoraRteMediaStreamType) {
        updateBottomItem(streamType: streamType)
        let userId = localUser.info.userId
        for i in 0..<infos.count {
            if infos[i].user.userId == userId, infos[i].type == .av {
                infos[i].avInfo.setStreamType(streamType: streamType)
                break
            }
        }
    }
    
    func updateBottomItem(streamType: AgoraRteMediaStreamType) {
        let hasVideo = streamType == .video || streamType == .audioAndVideo
        let hsaAudio = streamType == .audio || streamType == .audioAndVideo
        
        if hasVideo {
            if videoApplyTimer.isStarting { videoApplyTimer.stop() }
            let videoUpdate = BottomItemUpdateInfo(dataType: .video,
                                                   updateType: hasVideo ? .active : .inActive,
                                                   timeCount: 0)
            invokeMeetingVMShouldUpdateBottomItem(update: videoUpdate)
        }
        else {
            if !videoApplyTimer.isStarting {
                let videoUpdate = BottomItemUpdateInfo(dataType: .video,
                                                       updateType: hasVideo ? .active : .inActive,
                                                       timeCount: 0)
                invokeMeetingVMShouldUpdateBottomItem(update: videoUpdate)
            }
        }
        
        if hsaAudio {
            if audioApplyTimer.isStarting { audioApplyTimer.stop() }
            let audioUpdate = BottomItemUpdateInfo(dataType: .audio,
                                                   updateType: .active,
                                                   timeCount: 0)
            invokeMeetingVMShouldUpdateBottomItem(update: audioUpdate)
        }
        else {
            if !audioApplyTimer.isStarting {
                let audioUpdate = BottomItemUpdateInfo(dataType: .audio,
                                                       updateType: hsaAudio ? .active : .inActive,
                                                       timeCount: 0)
                invokeMeetingVMShouldUpdateBottomItem(update: audioUpdate)
            }
        }
    }
    
    func updateButtomViewIfNeed() {
        guard let localInfo = infos.filter({ $0.isMe && !$0.isShare }).first else {
            return
        }
        let streamType = localInfo.avInfo.streamType
        updateBottomItem(streamType: streamType)
    }
    
    func removeLocalStream(event: AgoraRteMediaStreamEvent) {
        if event.modifiedStream.streamName == "ScreenShare" {
            return
        }
        Log.debug(text: "removeLocalStream", tag: "fetchInfos")
        updateLocalStream(streamType: .none)
    }
    
}
