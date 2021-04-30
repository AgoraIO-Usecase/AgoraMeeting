//
//  MeetingVM+AV.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/15.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte
import AgoraRoom

extension MeetingVM {
    
    func renderView(view: UIView, info: Info) {
        switch info.type {
        case .av:
            info.isMe ? ARConferenceManager.renderLocalView(view) : ARConferenceManager.renderRemoteView(view, streamId: info.avInfo.streamId)
            if info.isMe { Log.debug(text: "\(info.user.userName)") }
            else { Log.debug(text: "执行渲染远程视频流 \(info.user.userName), streamId: \(info.avInfo.streamId)") }
            break
        case .screen:
            ARConferenceManager.renderRemoteView(view, streamId: info.screenInfo.streamId)
            Log.debug(text: "渲染屏幕共享 streamId: \(info.screenInfo.streamId) \(view.description)")
            break
        case .board:
            break
        }
    }
    
    func renderView(view: UIView, type: Info.InfoType, streamId: String, isMe: Bool) {
        switch type {
        case .av:
            isMe ? ARConferenceManager.renderLocalView(view) : ARConferenceManager.renderRemoteView(view, streamId: streamId)
            break
        case .screen:
            ARConferenceManager.renderRemoteView(view, streamId: streamId)
            break
        case .board:
            break
        }
    }
    
    func subscribeAudio(infos: [Info]) {
        for info in infos {
            if info.isMe { continue }
            guard info.type == .av, info.avInfo.streamType.hasAudio else {
                continue
            }
            let e = localUser.subscribeRemoteStream(info.avInfo.streamId, type: .audio)
            if e != nil {
                let s = "\(info.user.userName) av) e: \(e?.message ?? "无")"
                Log.errorText(text: s, tag: "localUser.subscribe")
            }
        }
    }
    
    /// subscribeVideo for low
    func subscribeVideo(infos: [Info], options: AgoraRteSubscribeOptions) {
        for info in infos {
            if info.isMe { continue }
            subscribeVideo(info: info, options: options)
        }
    }
    
    /// subscribeVideo for options
    func subscribeVideo(info: Info, options: AgoraRteSubscribeOptions) {
        if info.isMe { return }
        guard info.type != .board else {
            return
        }
        guard info.avInfo.streamType.hasVideo || info.screenInfo.streamId != "" else {
            return
        }
        let streamId = info.type == .av ? info.avInfo.streamId : info.screenInfo.streamId
        localUser.subscribeRemoteVideoStreamOptions(streamId, options: options)
    }
    
    /// subscribeVideo for screen or av
    public func subscribeVideo(userId: String,
                               streamId: String,
                               options: AgoraRteSubscribeOptions) {
        if streamId.count == 0 { return }
        let temp = infos
        let infos = temp.filter({ $0.user.userId == userId && $0.streamId == streamId })
        subscribeVideo(infos: infos, options: options)
    }
    
    public func unsubscribe(infos: [Info], onlyVideo: Bool = false) {
        for info in infos {
            if info.type == .board { continue }
            let type: AgoraRteMediaStreamType = onlyVideo ? .audio : info.avInfo.streamType
            let e = localUser.unsubscribeRemoteStream(info.avInfo.streamId, type: type)
            let s = "\(info.user.userId) \(info.avInfo.streamType.rawValue) e: \(e?.message ?? "无")"
            Log.info(text: s, tag: "localUser.unsubscribe")
        }
    }
    
    public func unsubscribe(userId: String, streamId: String) {
        if streamId.count == 0 { return }
        let temp = infos
        let infos = temp.filter({ $0.user.userId == userId && $0.streamId == streamId })
        unsubscribe(infos: infos, onlyVideo: true)
    }
    
    public func setVideo(enable: Bool) {
        if enable, localUser.info.isHost {
            requestVideoOpen(videoOpenShouldApply: false)
            return
        }
        if enable {
            willRequestVideoOpen()
            return
        }

        requestLocalVideoClose()
    }
    
    public func setAudio(enable: Bool) {
        if enable, localUser.info.isHost {
            requestAudioOpen(audioOpenShouldApply: false)
            return
        }
        if enable {
            willRequestAudioOpen()
            return
        }
        requestLocalAudioClose()
    }
    
    func switchCamare() {
        let track = ARConferenceManager.getRteEngine().getAgoraMediaControl().createCameraVideoTrack()
        track.switchCamera()
    }
    
    /// close all video or Audio
    func closeAllRemoteVideoAudio(isVideo: Bool) {
        guard localUser.info.isHost else {
            return
        }
        
        let userId = localUser.info.userId
        let roomUuid = ARConferenceManager.getEntryParams().roomUuid
        
        let reqParams = HMRequestParamsUserPermissionsCloseAll()
        reqParams.roomId = roomUuid
        reqParams.userId = userId
        if isVideo {
            reqParams.cameraClose = true
            reqParams.micClose = false
        }
        else {
            reqParams.cameraClose = false
            reqParams.micClose = true
        }
        invokeMeetingVMShouldShowLoading()
        
        HttpManager.requestAVCloseAll(reqParams) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func closeAllRemoteVideoAudio(isVideo: Bool, checkBox: Bool) {
        closeAllRemoteVideoAudio(isVideo: isVideo)
        if checkBox {
            isVideo ? setVideoAccess(checkBox: true) : setAudioAccess(checkBox: true)
        }
    }
    
    func setVideoAccess(checkBox: Bool) {
        invokeMeetingVMShouldShowLoading()
        let info = setVCInfo
        let reqParams = HMReqParamsUserPermissionsAll()
        ARConferenceManager.getScene()
        reqParams.cameraAccess = checkBox ? false : true
        reqParams.micAccess = !info.openAudioShoudApprove
        reqParams.roomId = info.roomId
        reqParams.userId = info.userId
        HttpManager.requestUserPermissionsUpdate(reqParams) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
        } failure: { [weak self] (error) in
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func setAudioAccess(checkBox: Bool) {
        invokeMeetingVMShouldShowLoading()
        let reqParams = HMReqParamsUserPermissionsAll()
        let info = setVCInfo
        reqParams.cameraAccess = !info.openVideoShoudApprove
        reqParams.micAccess = checkBox ? false : true
        reqParams.roomId = info.roomId
        reqParams.userId = info.userId
        HttpManager.requestUserPermissionsUpdate(reqParams) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
        } failure: { [weak self] (error) in
            self?.invokeMeetingVMShouldDismissLoading()
        }
    }
    
    func requestLocalVideoClose() {
        let param = HMReqParamsUserPermissionsCloseSingle()
        param.roomId = ARConferenceManager.getScene().info.sceneId
        param.userId = localUser.info.userId
        param.micClose = false
        param.cameraClose = true
        param.targetUserId = localUser.info.userId
        invokeMeetingVMShouldShowLoading()
        invokeMeetingVMShouldChangeBottomViewState(isVideo: true, enable: false)
        HttpManager.reqCloseCameraMicSingle(param) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
            self?.invokeMeetingVMShouldChangeBottomViewState(isVideo: true, enable: true)
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
    
    func requestLocalAudioClose() {
        let param = HMReqParamsUserPermissionsCloseSingle()
        param.roomId = ARConferenceManager.getScene().info.sceneId
        param.userId = localUser.info.userId
        param.micClose = true
        param.cameraClose = false
        param.targetUserId = localUser.info.userId
        invokeMeetingVMShouldShowLoading()
        invokeMeetingVMShouldChangeBottomViewState(isVideo: false, enable: false)
        HttpManager.reqCloseCameraMicSingle(param) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
            self?.invokeMeetingVMShouldChangeBottomViewState(isVideo: false, enable: true)
        } failure: { [weak self](error) in
            self?.invokeMeetingVMShouldDismissLoading()
            self?.invokeMeetingVMShouldChangeBottomViewState(isVideo: false, enable: true)
            if let e = error as? ARError {
                if e.code != 32400005 {
                    self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
                }
            }
        }
    }
}
