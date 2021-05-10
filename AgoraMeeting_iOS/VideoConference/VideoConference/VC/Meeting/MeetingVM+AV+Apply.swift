//
//  MeetingVM+ApplyAV.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/6.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte
import AgoraRoom

extension MeetingVM {
    
    func willRequestVideoOpen() {
        guard let userPermission = ARConferenceManager.getScene().readUserPermission() else {
            return
        }
        let roomHasHost = infos.hasHost
        (userPermission.videoOpenShouldApply && roomHasHost) ? invokeMeetingVMShouldShowRequestCameraAlertVC() : requestVideoOpen(videoOpenShouldApply: false)
    }
    
    func willRequestAudioOpen() {
        guard let userPermission = ARConferenceManager.getScene().readUserPermission() else {
            return
        }
        let roomHasHost = infos.hasHost
        (userPermission.audioOpenShouldApply && roomHasHost) ? invokeMeetingVMShouldShowRequestMicAlertVC() : requestAudioOpen(audioOpenShouldApply: false)
    }
    
    func requestVideoOpen(videoOpenShouldApply: Bool) {
        let param = HMReqParamsUserPermissionsAll()
        param.roomId = ARConferenceManager.getScene().info.sceneId
        param.userId = localUser.info.userId
        param.cameraAccess = true
        param.micAccess = false
        invokeMeetingVMShouldShowLoading()
        invokeMeetingVMShouldChangeBottomViewState(isVideo: true, enable: false)
        HttpManager.requestPermissionApply(withParam: param) { [weak self](_) in
            self?.invokeMeetingVMShouldDismissLoading()
            videoOpenShouldApply ? self?.startRequestVideoTimer() : self?.invokeMeetingVMShouldChangeBottomViewState(isVideo: true, enable: true)
        } failure: { [weak self](error) in
            self?.invokeMeetingVMShouldDismissLoading()
            self?.invokeMeetingVMShouldChangeBottomViewState(isVideo: true, enable: true)
            if let e = error as? ARError {
                if e.code != 32400005 {
                    self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
                }
            }
        }
    }
    
    func requestAudioOpen(audioOpenShouldApply: Bool) {
        let param = HMReqParamsUserPermissionsAll()
        param.roomId = ARConferenceManager.getScene().info.sceneId
        param.userId = localUser.info.userId
        param.cameraAccess = false
        param.micAccess = true
        invokeMeetingVMShouldShowLoading()
        invokeMeetingVMShouldChangeBottomViewState(isVideo: false, enable: false)
        HttpManager.requestPermissionApply(withParam: param) { [weak self](_) in
            self?.invokeMeetingVMShouldDismissLoading()
            audioOpenShouldApply ? self?.startRequestAudioTimer() : self?.invokeMeetingVMShouldChangeBottomViewState(isVideo: false, enable: true)
        } failure: { [weak self](error) in
            self?.invokeMeetingVMShouldDismissLoading()
            self?.invokeMeetingVMShouldChangeBottomViewState(isVideo: false, enable: true)
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func updateAudioItemCount(_ count: Int) {
        let update = BottomItemUpdateInfo(dataType: .audio,
                                          updateType: .time,
                                          timeCount: count)
        invokeMeetingVMShouldUpdateBottomItem(update: update)
    }
    
    func updateVideoItemCount(_ count: Int) {
        let update = BottomItemUpdateInfo(dataType: .video,
                                          updateType: .time,
                                          timeCount: count)
        invokeMeetingVMShouldUpdateBottomItem(update: update)
    }
    
    func updateAudioItemEndCount() {
        let localUserId = localUser.info.userId
        let streams = ARConferenceManager.getScene().streams
        if let localVideoSream = streams.filter({ $0.owner.userId == localUserId }).first {
            let hasVideo = localVideoSream.streamType == .audioAndVideo || localVideoSream.streamType == .audio
            let updateType: BottomItemUpdateInfo.UpdateType = hasVideo ? .active : .inActive
            let update = BottomItemUpdateInfo(dataType: .audio,
                                              updateType: updateType,
                                              timeCount: 0)
            invokeMeetingVMShouldUpdateBottomItem(update: update)
            return
        }
        let update = BottomItemUpdateInfo(dataType: .audio,
                                          updateType: .inActive,
                                          timeCount: 0)
        invokeMeetingVMShouldUpdateBottomItem(update: update)
    }
    
    func updateVideoItemEndCount() {
        let localUserId = localUser.info.userId
        let streams = ARConferenceManager.getScene().streams
        if let localVideoSream = streams.filter({ $0.owner.userId == localUserId }).first {
            let hasVideo = localVideoSream.streamType == .audioAndVideo || localVideoSream.streamType == .video
            let updateType: BottomItemUpdateInfo.UpdateType = hasVideo ? .active : .inActive
            let update = BottomItemUpdateInfo(dataType: .video,
                                              updateType: updateType,
                                              timeCount: 0)
            invokeMeetingVMShouldUpdateBottomItem(update: update)
            return
        }
        let update = BottomItemUpdateInfo(dataType: .video,
                                          updateType: .inActive,
                                          timeCount: 0)
        invokeMeetingVMShouldUpdateBottomItem(update: update)
    }
    
    func startRequestVideoTimer() {
        videoApplyTimer.start(duratedCount: 20)
    }
    
    func startRequestAudioTimer() {
        audioApplyTimer.start(duratedCount: 20)
    }
    
    func acceptCameraMicOpen(targetUserId: String, requestId: String, timeStamp: TimeInterval) {
        let parsms = HMReqParamsUserPermissionsRequestAccept()
        parsms.requestId = requestId
        parsms.roomId = ARConferenceManager.getScene().info.sceneId
        parsms.targetUserId = targetUserId
        parsms.userId = localUser.info.userId
        invokeMeetingVMShouldShowLoading()
        HttpManager.requestUserPermissionsRequestAcceptWitthParam(parsms) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
            NotiCollector.default.setActionIsSuccess(timeStamp: timeStamp)
        } failure: { [weak self](error) in
            self?.invokeMeetingVMShouldDismissLoading()
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
}

extension MeetingVM: TimerSourceDelegate {
    func timerDidUpdate(timer: TimerSource, current count: Int) {
        if timer == audioApplyTimer {
            updateAudioItemCount(count)
            return
        }
        if timer == videoApplyTimer {
            updateVideoItemCount(count)
            return
        }
    }
    
    func timerDidEnd(timer: TimerSource) {
        if timer == audioApplyTimer {
            updateAudioItemEndCount()
            return
        }
        if timer == videoApplyTimer {
            updateVideoItemEndCount()
            return
        }
        if timer == autoHidenTimerSource {
            shouldUpdateMessageHidden()
            return
        }
    }
}
