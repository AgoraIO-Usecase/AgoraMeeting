//
//  MemberVM.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/18.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRoom

protocol MemberVMDelegate: NSObject {
    func memberVMDidUpdateInfos(infos: [MemberVM.Info])
    func memberVMShouldShowLoading()
    func memberVMShouldDismissLoading()
    func memberVMShouldShowToast(text: String)
    func memberVMDidRequestHostError(error: NSError)
    func memberVMShouldShowVideoAlert()
    func memberVMShouldShowAudioAlert()
    func memberVMDidRequestVideoOpen()
    func memberVMDidRequestAudioOpen()
}

class MemberVM {
    private var infos: [Info]!
    weak var delegate: MemberVMDelegate?
    
    init(infos: [Info]) {
        if let shareInfo = infos.filter({ $0.uiInfo.isShare }).first {
            var temps = infos.filter({ !$0.uiInfo.isShare })
            let count = temps.count
            for i in 0..<count {
                if temps[i].userId == shareInfo.userId {
                    var info = temps[i]
                    info.uiInfo.setShare(share: true)
                    temps[i] = info
                    break
                }
            }
            self.infos = temps.sorted(by: sortHandle(lhs:rhs:))
        }
        else {
            self.infos = infos.sorted(by: sortHandle(lhs:rhs:))
        }
    }
    
    func start() {
        setNormalDisplay()
    }
    
    func search(text: String) {
        var temps = [MemberVM.Info]()
        for var info in infos {
            let title = info.uiInfo.title
            if title.contains(text) {
                let range = (NSString(string: title)).range(of: text)
                let attributedString = NSMutableAttributedString(string: title)
                attributedString.addAttribute(.foregroundColor, value: UIColor(hex: 0x4DA1FF), range: range)
                info.uiInfo.setAttributeTitle(attributedTitle: attributedString)
                temps.append(info)
            }
        }
        
        delegate?.memberVMDidUpdateInfos(infos: temps)
    }
    
    func setNormalDisplay() {
        let temps = infos!.map { (info) -> Info  in
            var temp = info
            let title = info.uiInfo.title
            temp.uiInfo.setAttributeTitle(attributedTitle: NSMutableAttributedString(string: title))
            return temp
        }
        delegate?.memberVMDidUpdateInfos(infos: temps)
    }
    
    func kickOut(currentUserInfo: Info, info: Info) {
        let reqParams = HMReqParamsKickout()
        reqParams.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParams.userId = currentUserInfo.userId
        reqParams.targetUserId = info.userId
        HttpManager.request(reqParams) {
            self.delegate?.memberVMShouldShowLoading()
        } failure: { (error) in
            self.delegate?.memberVMShouldShowToast(text: error.localizedDescription)
        }

    }
    
    func setLocalVideo(enable: Bool) {
        if !enable {
            closeLocalVideo()
            return
        }
        
        let localUser = ARConferenceManager.getLocalUser()
        let isHost = localUser.info.isHost
        
        if isHost {
            requestVideoOpen(audioOpenSHouldApply: false)
            return
        }
        
        guard let userPermission = ARConferenceManager.getScene().readUserPermission() else {
            return
        }
        
        userPermission.videoOpenShouldApply ? delegate?.memberVMShouldShowVideoAlert() : requestVideoOpen(audioOpenSHouldApply: false)
    }
    
    func setLocalAudio(enable: Bool) {
        if !enable {
            closeLocalAudio()
            return
        }
        
        let localUser = ARConferenceManager.getLocalUser()
        let isHost = localUser.info.isHost
        
        if isHost {
            requestAudioOpen(audioOpenSHouldApply: false)
            return
        }
        
        guard let userPermission = ARConferenceManager.getScene().readUserPermission() else {
            return
        }
        
        userPermission.audioOpenShouldApply ? delegate?.memberVMShouldShowAudioAlert() : requestAudioOpen(audioOpenSHouldApply: false)
    }
    
    func requestVideoOpen(audioOpenSHouldApply: Bool) {
        let localUser = ARConferenceManager.getLocalUser()
        let param = HMReqParamsUserPermissionsAll()
        param.roomId = ARConferenceManager.getScene().info.sceneId
        param.userId = localUser.info.userId
        param.cameraAccess = true
        param.micAccess = false
        delegate?.memberVMShouldShowLoading()
        HttpManager.requestPermissionApply(withParam: param) { [weak self](_) in
            self?.delegate?.memberVMShouldDismissLoading()
            audioOpenSHouldApply ? self?.delegate?.memberVMDidRequestVideoOpen() : nil
        } failure: { [weak self](error) in
            self?.delegate?.memberVMShouldShowToast(text: error.localizedDescription)
        }
    }
    
    func requestAudioOpen(audioOpenSHouldApply: Bool) {
        let localUser = ARConferenceManager.getLocalUser()
        let param = HMReqParamsUserPermissionsAll()
        param.roomId = ARConferenceManager.getScene().info.sceneId
        param.userId = localUser.info.userId
        param.cameraAccess = false
        param.micAccess = true
        delegate?.memberVMShouldShowLoading()
        HttpManager.requestPermissionApply(withParam: param) { [weak self](_) in
            self?.delegate?.memberVMShouldDismissLoading()
            audioOpenSHouldApply ? self?.delegate?.memberVMDidRequestAudioOpen() : nil
        } failure: { [weak self](error) in
            self?.delegate?.memberVMShouldShowToast(text: error.localizedDescription)
        }
    }
    
    func abandonHost() {
        let reqParams = HMReqParamsHostAbondon()
        reqParams.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParams.userId = ARConferenceManager.getEntryParams().userUuid
        delegate?.memberVMShouldShowLoading()
        HttpManager.requestHostAbandon(withParam: reqParams) { [weak self] in
            self?.delegate?.memberVMShouldDismissLoading()
            Log.info(text: "abandonHost success \(reqParams.userId)")
        } failure: { [weak self](error) in
            self?.delegate?.memberVMShouldShowToast(text: error.localizedDescription)
            Log.errorText(text: "error: \(error)", tag: "abandonHost")
        }
    }
    
    func beHost() {
        let reqParams = HMReqParamsHostAbondon()
        reqParams.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParams.userId = ARConferenceManager.getEntryParams().userUuid
        delegate?.memberVMShouldShowLoading()
        HttpManager.requestHostApply(withParam: reqParams) { [weak self] in
            self?.delegate?.memberVMShouldDismissLoading()
            Log.info(text: "beHost success \(reqParams.userId)")
        } failure: { [weak self](error) in
            self?.delegate?.memberVMShouldShowToast(text: error.localizedDescription)
            Log.errorText(text: "error: \(error)", tag: "beHost")
            
        }
    }
    
    /// 设为主持人
    func setHost(info: Info) {
        let reqParam = HMReqParamsKickout()
        reqParam.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParam.userId = ARConferenceManager.getLocalUser().info.userId
        reqParam.targetUserId = info.userId
        delegate?.memberVMShouldShowLoading()
        HttpManager.requestAppointHost(withParam: reqParam) { [weak self] in
            self?.delegate?.memberVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.delegate?.memberVMShouldShowToast(text: error.localizedDescription)
            Log.errorText(text: "error: \(error)", tag: "beHost")
        }
    }
    
    func updateInfos(infos: [Info], mode: Mode, searchText: String) {
        if let shareInfo = infos.filter({ $0.uiInfo.isShare }).first {
            var temps = infos.filter({ !$0.uiInfo.isShare })
            let count = temps.count
            for i in 0..<count {
                if temps[i].userId == shareInfo.userId {
                    var info = temps[i]
                    info.uiInfo.setShare(share: true)
                    temps[i] = info
                    break
                }
            }
            self.infos = temps.sorted(by: sortHandle(lhs:rhs:))
        }
        else {
            self.infos = infos.sorted(by: sortHandle(lhs:rhs:))
        }
        mode == .normal ? setNormalDisplay() : search(text: searchText)
    }
    
    func closeRemoteVideoAudio(isVideo: Bool, info: Info) {
        let localUser = ARConferenceManager.getLocalUser()
        let reqParams = HMReqParamsUserPermissionsCloseSingle()
        reqParams.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParams.userId = localUser.info.userId
        reqParams.targetUserId = info.userId
        if isVideo {
            reqParams.cameraClose = true
            reqParams.micClose = false
        }
        else {
            reqParams.cameraClose = false
            reqParams.micClose = true
        }
        self.delegate?.memberVMShouldShowLoading()
        HttpManager.reqCloseCameraMicSingle(reqParams) { [weak self] in
            self?.delegate?.memberVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.delegate?.memberVMShouldShowToast(text: error.localizedDescription)
        }
    }
    
    func closeLocalVideo() {
        let localUser = ARConferenceManager.getLocalUser()
        let param = HMReqParamsUserPermissionsCloseSingle()
        param.roomId = ARConferenceManager.getScene().info.sceneId
        param.userId = localUser.info.userId
        param.micClose = false
        param.cameraClose = true
        param.targetUserId = localUser.info.userId
        self.delegate?.memberVMShouldShowLoading()
        HttpManager.reqCloseCameraMicSingle(param) { [weak self] in
            self?.delegate?.memberVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.delegate?.memberVMShouldShowToast(text: error.localizedDescription)
        }
    }
    
    func closeLocalAudio() {
        let localUser = ARConferenceManager.getLocalUser()
        let param = HMReqParamsUserPermissionsCloseSingle()
        param.roomId = ARConferenceManager.getScene().info.sceneId
        param.userId = localUser.info.userId
        param.micClose = true
        param.cameraClose = false
        param.targetUserId = localUser.info.userId
        self.delegate?.memberVMShouldShowLoading()
        HttpManager.reqCloseCameraMicSingle(param) { [weak self] in
            self?.delegate?.memberVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.delegate?.memberVMShouldShowToast(text: error.localizedDescription)
        }
    }
    
    var currentUserInfo: MemberVM.Info? {
        let temp = infos
        let localUserId = ARConferenceManager.getLocalUser().info.userId
        let user = temp?.filter({ $0.uiInfo.userId == localUserId }).first
        if user == nil {
            Log.errorText(text: "user == nil" + ":"
                          + localUserId, tag: "MemberVM.currentUserInfo")
        }
        return user
    }
    
    private func sortHandle(lhs: Info, rhs: Info) -> Bool {
        
        var lhsValue = 0
        var rhsValue = 0
        
        lhs.uiInfo.isHost ? lhsValue += 10 : nil
        rhs.uiInfo.isHost ? rhsValue += 10 : nil
        
        lhs.isMe ? lhsValue += 100 : nil
        rhs.isMe ? rhsValue += 100 : nil
        
        if lhsValue == rhsValue { return true }
        
        return lhsValue > rhsValue
    }
    
    
}

extension MemberVM {
    struct Info {
        let userId: String
        var uiInfo: UserCell.Info!
        
        var isMe: Bool {
            return ARConferenceManager.isMe(fromUserId: userId)
        }
    }
    
    enum Mode {
        case normal
        case searching
    }
}
