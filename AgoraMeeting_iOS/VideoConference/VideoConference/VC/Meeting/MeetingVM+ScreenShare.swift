//
//  MeetingVM+ScreenShare.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/3.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRoom

extension MeetingVM {
    
    func registerNotiFormScreenShareExtension() {
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let callback: CFNotificationCallback = { (_, observer, name, obj, userInfo) -> Void in
            if let observer = observer {
                let mySelf = Unmanaged<MeetingVM>.fromOpaque(observer).takeUnretainedValue()
                mySelf.stopScreenShareByExtension()
            }
        }
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        observer,
                                        callback,
                                        "com.videoconference.shareendbyapp" as CFString,
                                        nil,
                                        .deliverImmediately)
    }
    
    func unregisterNotiFormScreenShareExtension() {
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                           observer,
                                           CFNotificationName(rawValue: "com.videoconference.shareendbyapp" as CFString),
                                           nil)
    }
    
    func startScreenShare() {
        if #available(iOS 12.0, *) {
            let userId = localUser.info.userId
            let roomId = ARConferenceManager.getScene().info.sceneId
            let param = HMReqParamsHostAbondon()
            param.roomId = roomId
            param.userId = userId
            invokeMeetingVMShouldShowLoading()
            HttpManager.requestScreenShareStart(withParam: param) { [weak self](resp) in
                self?.screenInfo.token = resp.rtcToken
                self?.invokeMeetingVMShouldDismissLoading()
            } failure: { [weak self](error) in
                self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
            }
        } else {
            invokeMeetingVMDidErrorWithTips(tips: NSLocalizedString("系统版本12.0以上系统可用分享", comment: ""))
        }
    }
    
    func stopScreenShare() {
        guard let streamId = screenInfo.screenId else {
            let tips = "屏幕共享结束无效（非发起者）"
            Log.info(text: "screenInfo.screenId is nil", tag: "stopScreenShare")
            invokeMeetingVMDidErrorWithTips(tips: tips)
            return
        }
        let userId = localUser.info.userId
        let roomId = ARConferenceManager.getScene().info.sceneId
        let param = HMReqScreenShareStop()
        param.roomId = roomId
        param.userId = userId
        param.streamId = streamId
        invokeMeetingVMShouldShowLoading()
        HttpManager.requestScreenShareStop(withParam: param) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
            self?.sendNotiToExtensionForStop()
            self?.screenInfo.makeInValid()
        } failure: { [weak self](error) in
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func stopScreenShareByExtension() {
        guard let streamId = screenInfo.screenId else {
            return
        }
        let userId = localUser.info.userId
        let roomId = ARConferenceManager.getScene().info.sceneId
        let param = HMReqScreenShareStop()
        param.roomId = roomId
        param.userId = userId
        param.streamId = streamId
        
        HttpManager.requestScreenShareStop(withParam: param) { [weak self] in
            self?.screenInfo.makeInValid()
        } failure: { [weak self](error) in
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    /// fetch remote user's ScreenShare, when add a remote user
    func fetchScreenShareInRemoteUserAdd(events: [AgoraRteUserEvent], scene: AgoraRteScene) {
        let userIds = events.map({ $0.modifiedUser.userId })
        for userId in userIds {
            if fetchScreenShareInfo(scene: scene, targetUserId: userId) {
                return
            }
        }
    }
    
    /// fetch ScreenShare info when targetUserId is an owner
    /// - Returns: if true, no need to add a ScreenShare
    private func fetchScreenShareInfo(scene: AgoraRteScene, targetUserId: String) -> Bool {
        guard let shareType = readShareFrom(scene: scene) else {
            return false
        }
        switch shareType {
        case .screen:
            guard let sceneScreenInfo = readScreenId(scene: scene) else {
                return true
            }
            if targetUserId == sceneScreenInfo.userId {
                saveScreenId(id: sceneScreenInfo.screenId)
                let userId = sceneScreenInfo.userId
                let userName = sceneScreenInfo.userName
                let userRole = sceneScreenInfo.userRole
                let user = Info.User(userId: userId, userName: userName, userRole: userRole)
                let screenInfo = Info.ShareScreenInfo(streamId: sceneScreenInfo.screenId)
                let info = Info(type: .screen, user: user, screenInfo: screenInfo)
                addWhiteBoardInfoIfNeed(info: info)
                return true
            }
            return false
        default:
            return true
        }
    }
    
    func handleCheckScreenInfo(scene: AgoraRteScene) {
        guard let shareType = readShareFrom(scene: scene) else {
            return
        }
        switch shareType {
        case .screen:
            guard let sceneScreenInfo = readScreenId(scene: scene) else {
                return
            }
            if localUser.info.userId == sceneScreenInfo.userId { /** 自己发起的 **/
                saveScreenId(id: sceneScreenInfo.screenId)
                invokeMeetingVMShouldShowScreenShareView()
                let userId = sceneScreenInfo.userId
                let userName = sceneScreenInfo.userName
                let userRole = sceneScreenInfo.userRole
                let user = Info.User(userId: userId, userName: userName, userRole: userRole)
                let screenInfo = Info.ShareScreenInfo(streamId: sceneScreenInfo.screenId)
                let info = Info(type: .screen, user: user, screenInfo: screenInfo)
                addScreenShareIfNeed(info: info)
            }
            else {
                let userId = sceneScreenInfo.userId
                let userName = sceneScreenInfo.userName
                let userRole = sceneScreenInfo.userRole
                let user = Info.User(userId: userId, userName: userName, userRole: userRole)
                let screenInfo = Info.ShareScreenInfo(streamId: sceneScreenInfo.screenId)
                let info = Info(type: .screen, user: user, screenInfo: screenInfo)
                addScreenShareIfNeed(info: info)
            }
            break
        case .none:
            removeScreenShareInfo()
            break
        default:
            break
        }
    }
    
    func handleScreenInfoChange(scene: AgoraRteScene, cause: String?) {
        guard let causeString = cause else {
            Log.errorText(text: "cause is nil", tag: "handleScreenInfoChange")
            return
        }
        do {
            let cause = try Cause.decode(jsonString: causeString)
            let cmd = cause.getCmd
            switch cmd {
            case .startScreenShare:
                guard let sceneScreenInfo = readScreenId(scene: scene) else {
                    return
                }
                if localUser.info.userId == sceneScreenInfo.userId { /** 自己发起的 **/
                    Log.info(text: "screen share is me", tag: "handleScreenInfoChange")
                    saveScreenId(id: sceneScreenInfo.screenId)
                    invokeMeetingVMShouldShowScreenShareView()
                }
                else {
                    let str = "screen share is not me, sceneScreenInfo.userId = \(sceneScreenInfo.userId)"
                    Log.info(text: str, tag: "handleScreenInfoChange")
                }
                let userId = sceneScreenInfo.userId
                let userName = sceneScreenInfo.userName
                let userRole = sceneScreenInfo.userRole
                let user = Info.User(userId: userId, userName: userName, userRole: userRole)
                let screenInfo = Info.ShareScreenInfo(streamId: sceneScreenInfo.screenId)
                let info = Info(type: .screen, user: user, screenInfo: screenInfo)
                addScreenShareIfNeed(info: info)
                break
            case .closeScreenShare:
                Log.info(text: "closeScreenShare", tag: "handleScreenInfoChange")
                removeScreenShareInfo()
                break
            default:
                Log.info(text: "case default", tag: "handleScreenInfoChange")
                break
            }
        } catch let e {
            Log.errorText(text: "can not decode, cause: \(causeString)", tag: "handleScreenInfoChange")
            Log.error(error: e)
        }
    }
    
    func readScreenId(scene: AgoraRteScene) -> SceneScreenInfo? {
        let share = scene.readShareInfo()
        guard let screen = share?.screen else {
            return nil
        }
        return SceneScreenInfo(screenId: "\(screen.streamInfo.streamId)",
                               userId: screen.ownerInfo.userId,
                               userName: screen.ownerInfo.userName,
                               userRole: screen.ownerInfo.userRole)
    }
    
    func saveScreenId(id: String) {
        let roomId = ARConferenceManager.getScene().info.sceneId
        screenInfo.channnelId = roomId
        screenInfo.screenId = id
        Log.info(text: "saveScreenId:\(id)")
        if screenInfo.isValid { saveScreenParamInUserDefault() }
    }
    
    private func saveScreenParamInUserDefault() {
        guard let screenId = screenInfo.screenId,
              let token = screenInfo.token,
              let channnelId = screenInfo.channnelId else {
            let str = "screenInfo.screenId = \(screenInfo.screenId ?? "nil"), screenInfo.token = \(screenInfo.token ?? "nil") , screenInfo.channnelId = \(screenInfo.channnelId ?? "nil")"
            Log.errorText(text: "fail" + str, tag: "saveScreenParamInUserDefault")
            return
        }
        Log.info(text: "saveScreenId, screenId:\(screenId), token:\(token), channnelId:\(channnelId)", tag: "saveScreenParamInUserDefault")
        let userDefault = UserDefaults(suiteName: appGroupsString)
        userDefault?.setValue(KeyCenter.agoraAppid(), forKey: "appid")
        userDefault?.setValue(screenId, forKey: "screenid")
        userDefault?.setValue(token, forKey: "token")
        userDefault?.setValue(channnelId, forKey: "channelid")
        userDefault?.synchronize()
    }
    
    func sendNotiToExtensionForStop() {
        Log.info(text:"sendNotiToExtensionForStop ")
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let name = CFNotificationName("com.videoconference.exit" as CFString)
        let userInfo = [String : String]() as CFDictionary
        CFNotificationCenterPostNotification(center, name, nil, userInfo, true)
    }
    
    func addScreenShareIfNeed(info: MeetingVM.Info) {
        if infos.filter({ $0.type != .av }).count > 0 { return }
        Log.debug(text: "Add Info (screen): \(info.user.userName)", tag: "add info")
        infos.append(info)
        updateInfo(shouldAutoChangeToSpeakerMode: true)
    }
    
    func removeScreenShareInfo() {
        Log.info(text: "removeScreenShareInfo", tag: "removeScreenShareInfo")
        infos = infos.filter({ $0.type != .screen })
        updateInfo(shouldAutoChangeToSpeakerMode: true)
    }
}

extension MeetingVM {
    struct ScreenInfo {
        var screenId: String?
        var token: String?
        var channnelId: String?
        
        var isValid: Bool {
            return channnelId != nil && token != nil && screenId != nil
        }
        
        mutating func makeInValid() {
            screenId = nil
            token = nil
            channnelId = nil
        }
    }
    
    struct SceneScreenInfo {
        let screenId: String
        let userId: String
        let userName: String
        let userRole: String
         
    }
}
