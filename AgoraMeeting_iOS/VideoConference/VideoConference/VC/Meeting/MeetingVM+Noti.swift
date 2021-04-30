//
//  MeetingVM+Noti.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/21.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte
import AVFoundation
import AgoraRoom

extension MeetingVM {
    
    func addNotiObserver() {
        NotiCollector.default.delegate1 = self
        MessageCollector.default.delegate1 = self
    }
    
    func addEnterRoomNoti(events: [AgoraRteUserEvent]) {
        let type = NotiType(rawValue: ARUserDefaults.getNotiTypeValue())!
        let count = ARConferenceManager.getScene().users.count
        guard type != .never else {
            return
        }
        guard type == .always || count < type.rawValue * 10 else {
            return
        }
        let notis = events.map { (e) -> NotiCollector.Info in
            let userName = e.modifiedUser.userName
            let tipsMsg = NSLocalizedString("noti_t7", comment: "")
            return NotiCollector.Info(notiType: .enterRoom, tipsMsg: tipsMsg, targetUserName: userName)
        }
        NotiCollector.default.add(infos: notis)
    }
    
    func addLeaveRoomNoti(events: [AgoraRteUserEvent]) {
        let type = NotiType(rawValue: ARUserDefaults.getNotiTypeValue())!
        let count = ARConferenceManager.getScene().users.count
        guard type != .never else {
            return
        }
        guard type == .always || count < type.rawValue * 10 else {
            return
        }
        let notis = events.map ({ (e) -> NotiCollector.Info in
            let userName = e.modifiedUser.userName
            let tipsMsg = NSLocalizedString("noti_t6", comment: "")
            return NotiCollector.Info(notiType: .leaveRoom, tipsMsg: tipsMsg, targetUserName: userName)
        })
        NotiCollector.default.add(infos: notis)
    }
    
    func addBeKickoutNoti() {
        let tipsMsg = NSLocalizedString("meeting_t24", comment: "")
        let noti = NotiCollector.Info(notiType: .beKickout, tipsMsg: tipsMsg, targetUserName: nil)
        NotiCollector.default.add(infos: [noti])
    }
    
    func addRoomEndNoti() {
        let tipsMsg = NSLocalizedString("meeting_t3", comment: "")
        let noti = NotiCollector.Info(notiType: .roomEnd, tipsMsg: tipsMsg, targetUserName: nil)
        NotiCollector.default.add(infos: [noti])
    }
    
    func checkNoti() {
        let noHostNotis = checkNoHostNoti()
        let cameraMicAuthNotis = checkCameraMicAuthNoti()
        let temps = noHostNotis + cameraMicAuthNotis
        NotiCollector.default.add(infos: temps)
        
        checkAttendsNumberNotiIfNeed()
    }
    
    func addAlawaysCloseNotiIfNeed() {
        let type = NotiType(rawValue: ARUserDefaults.getNotiTypeValue())!
        guard type == .never else {
            return
        }
        
        let notis = NotiCollector.default.getAll()
        if notis.count == 0 || (notis.count > 0 && notis.last!.notiType != .alwayCloseNoti) {
            let tipsMsg = NSLocalizedString("meeting_t28", comment: "")
            let noti = NotiCollector.Info(notiType: .alwayCloseNoti, tipsMsg: tipsMsg, targetUserName: nil)
            NotiCollector.default.add(infos:[noti])
        }
    }
    
    func checkNotiNoHost() {
        let noHostNotis = checkNoHostNoti()
        NotiCollector.default.add(infos: noHostNotis)
    }
    
    private func checkNoHostNoti() -> [NotiCollector.Info] {
        let notis = NotiCollector.default.getAll().filter({ $0.notiType == .newHost || $0.notiType == .noHostAction })
        if let last = notis.last, last.notiType == .noHostAction {
            return []
        }
        
        let temp = ARConferenceManager.getScene().users
        let hasHost = temp.contains(where: { $0.isHost })
        guard !hasHost else {
            return []
        }
        
        let tipsMsg = NSLocalizedString("noti_t8", comment: "")
        let buttonTitle = NSLocalizedString("noti_t5", comment: "")
        let noti = NotiCollector.Info(notiType: .noHostAction,
                                      tipsMsg: tipsMsg,
                                      targetUserName: nil,
                                      targetUserId: nil,
                                      timeCount: nil,
                                      buttonTitle: buttonTitle,
                                      successButtonTitle: "")
        return [noti]
    }
    
    func checkAttendsNumberNotiIfNeed() {
        let notis = NotiCollector.default.getAll()
        var attendsNumberNotis =  checkAttendsNumberNoti()
        if  attendsNumberNotis.count > 0, let noti = attendsNumberNotis.first, let last = notis.filter({ $0.notiType.isMaxAttendNoti }).last {
            if noti.notiType == last.notiType { attendsNumberNotis.removeAll() }
        }
        NotiCollector.default.add(infos: attendsNumberNotis)
    }
    
    private func checkAttendsNumberNoti() -> [NotiCollector.Info] {
        let type = NotiType(rawValue: ARUserDefaults.getNotiTypeValue())!
        switch type {
        case .always, .never:
            break
        default:
            let n = type.rawValue * 10
            if infos.count > n {
                
                let tipsMsg = NSLocalizedString("meeting_t59", comment: "") + "\(n)" + NSLocalizedString("meeting_t60", comment: "")
                let buttonTitle = NSLocalizedString("meeting_t4", comment: "")
                let noti = NotiCollector.Info(notiType: type.notiCollectorNotiType!,
                                              tipsMsg: tipsMsg,
                                              targetUserName: nil,
                                              targetUserId: nil,
                                              timeCount: 0,
                                              buttonTitle: buttonTitle,
                                              successButtonTitle: "")
                return [noti]
            }
            break
        }
        return []
    }
    
    
    private func checkCameraMicAuthNoti() -> [NotiCollector.Info] {
        let isContainCameraAuth = NotiCollector.default.getAll().contains(where: { $0.notiType == .cameraNotAuthAction })
        let isContainMicAuth = NotiCollector.default.getAll().contains(where: { $0.notiType == .micNotAuthAction })
        var temps = [NotiCollector.Info]()
        if !isContainCameraAuth {
            let cameraAuth = isCameraAuth
            if !cameraAuth {
                let tipsMsg = NSLocalizedString("meeting_t31", comment: "")
                let noti = NotiCollector.Info(notiType: .cameraNotAuthAction,
                                              tipsMsg: tipsMsg,
                                              targetUserName: nil,
                                              targetUserId: nil,
                                              timeCount: nil,
                                              buttonTitle: NSLocalizedString("noti_t13", comment: ""),
                                              successButtonTitle: "")
                temps.append(noti)
            }
        }
        if !isContainMicAuth {
            let micAuth = isMicAuth
            if !micAuth {
                let tipsMsg = NSLocalizedString("meeting_t45", comment: "")
                let noti = NotiCollector.Info(notiType: .micNotAuthAction,
                                              tipsMsg: tipsMsg,
                                              targetUserName: nil,
                                              targetUserId: nil,
                                              timeCount: nil,
                                              buttonTitle: NSLocalizedString("noti_t13", comment: ""),
                                              successButtonTitle: "")
                temps.append(noti)
            }
        }
        return temps
    }
    
    func checkAllClose(closeAllInfo: ChannelMesssageCloseAllCaremaMic) {
        switch closeAllInfo.data.deviceType {
        case .camera:
            let tipsMsg = NSLocalizedString("meeting_t7", comment: "")
            let noti = NotiCollector.Info(notiType: .closeAllCamera, tipsMsg: tipsMsg, targetUserName: nil)
            NotiCollector.default.add(infos: [noti])
            break
        case .mic:
            let tipsMsg = NSLocalizedString("meeting_t8", comment: "")
            let noti = NotiCollector.Info(notiType: .closeAllMic, tipsMsg: tipsMsg, targetUserName: nil)
            NotiCollector.default.add(infos: [noti])
            break
        }
    }
    
    func checkLocalStreamUpdateNoti(event: AgoraRteMediaStreamEvent) {
        guard let causeString = event.cause else {
            return
        }
        do {
            let cause = try Cause.decode(jsonString: causeString)
            switch cause.getCmd {
            case .closeSingleCameraDevices:
                let tipsMsg = NSLocalizedString("meeting_t1", comment: "")
                let noti = NotiCollector.Info(notiType: .closeSingleCamera, tipsMsg: tipsMsg, targetUserName: nil)
                NotiCollector.default.add(infos: [noti])
                break
            case .closeSingleMicDevices:
                let tipsMsg = NSLocalizedString("meeting_t2", comment: "")
                let noti = NotiCollector.Info(notiType: .closeSingleMic, tipsMsg: tipsMsg, targetUserName: nil)
                NotiCollector.default.add(infos: [noti])
            case .closeAllMicDevices, .closeAllCameraDevices:
                /// 这里由 update room property 提供
                break
            default:
                break
            }
        } catch let e {
            Log.info(text: causeString)
            Log.error(error: e, tag: "checkLocalStreamUpdateNoti")
        }
    }
    
    func checkRemoteUserInfoUpdateNoti(event: AgoraRteUserEvent) {
        if event.modifiedUser.isHost {
            /// 新主持人
            let tipsMsg = NSLocalizedString("noti_t14", comment: "")
            let noti = NotiCollector.Info(notiType: .newHost, tipsMsg: tipsMsg, targetUserName: event.modifiedUser.userName)
            NotiCollector.default.add(infos: [noti])
        }
    }
    
    func checkLocalUserInfoUpdateNoti(event: AgoraRteUserEvent) {
        checkRemoteUserInfoUpdateNoti(event: event)
    }
    
    func checkCameraMicAccessNoti(scene: AgoraRteScene) -> [NotiCollector.Info] {
        guard let userPermission = scene.readUserPermission() else {
            sceneProperties = scene.properties
            return []
        }
        
        let oldUserPermission = AgoraRteScene.readUserPermission(properties: sceneProperties)
        var shouldAddMic = true
        var shouldAddCamera = true
        
        if let oldValue = oldUserPermission {
            shouldAddMic = oldValue.audioOpenShouldApply != userPermission.audioOpenShouldApply
            shouldAddCamera = oldValue.videoOpenShouldApply != userPermission.videoOpenShouldApply
        }
        
        var temp = [NotiCollector.Info]()
        
        if shouldAddMic {
            // - 开启麦克风需要主持人批准
            // - 可以自由打开麦克风
            let tipsMsg = userPermission.audioOpenShouldApply ? NSLocalizedString("meeting_t20", comment: "") : NSLocalizedString("meeting_t13", comment: "")
            let type: NotiCollector.Info.NotiType = userPermission.audioOpenShouldApply ? .audioOpenShouldApply : .audioOpenFree
            let noti = NotiCollector.Info(notiType: type, tipsMsg: tipsMsg, targetUserName: nil)
            temp.append(noti)
        }
        
        if shouldAddCamera {
            // - 开启摄像头需要主持人批准
            // - 可以自由打开摄像头
            let tipsMsg = userPermission.videoOpenShouldApply ? NSLocalizedString("meeting_t19", comment: "") : NSLocalizedString("meeting_t12", comment: "")
            let type: NotiCollector.Info.NotiType = userPermission.audioOpenShouldApply ? .audioOpenShouldApply : .audioOpenFree
            let noti = NotiCollector.Info(notiType: type, tipsMsg: tipsMsg, targetUserName: nil)
            temp.append(noti)
        }
        
        sceneProperties = scene.properties
        return temp
        
    }
    
    func checkScenePropertyUpdateNoti(scene: AgoraRteScene, cause: String?) {
        guard let causeString = cause else {
            Log.info(text: "=== causeString err")
            return
        }
        do {
            let cause = try Cause.decode(jsonString: causeString)
            let cmd = cause.getCmd
            switch cmd {
            case .userPermissionChanged:
                let notis = checkCameraMicAccessNoti(scene: scene)
                NotiCollector.default.add(infos: notis)
                Log.info(text: "=== add userPermissionChanged")
                break
            case .startBoard:
                if let board = scene.readBoardInfo() {
                    let userName = board.ownerInfo.userName
                    let tipsMsg = NSLocalizedString("noti_t9", comment: "")
                    let noti = NotiCollector.Info(notiType: .boardStart, tipsMsg: tipsMsg, targetUserName: userName)
                    NotiCollector.default.add(infos: [noti])
                }
                break
            case .closeBoard:
                if let board = scene.readBoardInfo() {
                    let userName = board.ownerInfo.userName
                    let tipsMsg = NSLocalizedString("noti_t11", comment: "")
                    let noti = NotiCollector.Info(notiType: .boardEnd, tipsMsg: tipsMsg, targetUserName: userName)
                    NotiCollector.default.add(infos: [noti])
                }
                else {
                    Log.errorText(text: NSLocalizedString("meeting_t37", comment: ""))
                }
                break
            case .boardInteracts:
                if let board = scene.readBoardInfo(),
                   let userId = board.state.grantUsers.last,
                   let userName = scene.users.filter({ $0.userId == userId }).first?.userName {
                    let tipsMsg = NSLocalizedString("noti_t12", comment: "")
                    let noti = NotiCollector.Info(notiType: .boardEnd, tipsMsg: tipsMsg, targetUserName: userName)
                    NotiCollector.default.add(infos: [noti])
                }
                break
            case .startScreenShare:
                if let share = scene.readShareInfo(), let userName = share.screen?.ownerInfo.userName {
                    let tipsMsg = NSLocalizedString("noti_t10", comment: "")
                    let noti = NotiCollector.Info(notiType: .screenShareStart, tipsMsg: tipsMsg, targetUserName: userName)
                    NotiCollector.default.add(infos: [noti])
                }
                break
            case .closeScreenShare:
                let tipsMsg = NSLocalizedString("meeting_t18", comment: "")
                let noti = NotiCollector.Info(notiType: .screenShareend, tipsMsg: tipsMsg, targetUserName: nil)
                NotiCollector.default.add(infos: [noti])
                break
            default:
                break
            }
        } catch let e {
            Log.info(text: causeString)
            Log.error(error: e, tag: "checkRoomPropertyUpdateNoti")
        }
        
    }
    
    func checkCameraMicOpenRequestNoti(message: PeerMessage) {
        
        guard message.cmd == 1 else {
            return
        }
        
        guard message.data.processUuid == "cameraAccess" || message.data.processUuid == "micAccess"  else {
            return
        }

        guard let action = message.data.actionType, action == .invite else {
            return
        }
        
        let targetUserName = message.data.fromUser.userName
        let targetUserId = message.data.fromUser.userUuid
        let tipsMsg = message.data.processUuid == "cameraAccess" ? NSLocalizedString("meeting_t34", comment: "") : NSLocalizedString("meeting_t35", comment: "")
        let notiType: NotiCollector.Info.NotiType = message.data.processUuid == "cameraAccess" ? .applyVideoAction : .applyAudioAction
        let buttonTitle = NSLocalizedString("meeting_t14", comment: "")
        let noti = NotiCollector.Info(notiType: notiType,
                                      tipsMsg: tipsMsg,
                                      targetUserName: targetUserName,
                                      targetUserId: targetUserId,
                                      timeCount: 20,
                                      buttonTitle: buttonTitle,
                                      successButtonTitle: NSLocalizedString("noti_t1", comment: ""))
        NotiCollector.default.add(infos: [noti])
        
    }
    
    func handleNotiButtonTap(model: MeetingMessageModel) {
        let value = model.typeValue
        let notiType = NotiCollector.Info.NotiType(rawValue: value)!
        switch notiType {
        case .applyAudioAction:
            acceptCameraMicOpen(targetUserId: model.targetUserId, requestId: "micAccess", timeStamp: model.timeStamp)
            break
        case .applyVideoAction:
            acceptCameraMicOpen(targetUserId: model.targetUserId, requestId: "cameraAccess", timeStamp: model.timeStamp)
            break
        case .noHostAction:
            setMeAsHost()
            break
        case .cameraNotAuthAction, .micNotAuthAction:
            invokeMeetingVmShouldShowSystemSettingPage()
            break
        default:
            notiType.isMaxAttendNoti ? invokeMeetingVmShouldShowSelectedNotiVC() : nil
            break
        }
    }
}

extension MeetingVM {
    
    private func shouldUpdateNotis(notis: [NotiCollector.Info]) {
        let count = notis.count
        let temps = count > 3 ? notis[count-3..<count].compactMap({ $0 }).reversed() : notis.reversed()
        let hasCountTime = temps.filter({ ($0.timeCount ?? 0 > 0) }).count > 0
        let hasNewInfo = lastNotiTime != temps.first?.timeStamp
        
        if !hasNewInfo, !hasCountTime {
            return
        }
        
        let ms = temps.map({ noti -> MeetingMessageModel in
            let m = MeetingMessageModel()
            m.name = noti.targetUserName
            m.info = noti.tipsMsg
            m.remianCount = UInt(noti.timeCount ?? 0)
            m.showButton = noti.hasAction
            m.buttonTitle = noti.success ? noti.successButtonTitle : noti.buttonTitle
            m.typeValue = noti.notiType.rawValue
            m.buttonEnable = noti.buttonEnable
            m.targetUserId = noti.targetUserId ?? ""
            m.timeStamp = noti.timeStamp
            return m
        })
         
        if (hasNewInfo && !hasCountTime) || (hasNewInfo && hasCountTime) {
            lastNotiTime = temps.first?.timeStamp
            autoHidenTimerSource.reStart(duratedCount: 10)
            invokeMeetingVMShouldUpdateNoti(models: ms)
            invokeMeetingVMShouldHidenMessageView(hidden: false)
            return
        }
        
        if !hasNewInfo, hasCountTime  {
            invokeMeetingVMShouldUpdateNoti(models: ms)
            return
        }
        
    }
    
    private var isCameraAuth: Bool {
        let state = AVCaptureDevice.authorizationStatus(for: .video)
        switch state {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            return true
        case .restricted:
            return true
        @unknown default:
            return true
        }
    }
    
    private var isMicAuth: Bool {
        let state = AVCaptureDevice.authorizationStatus(for: .audio)
        switch state {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            return true
        case .restricted:
            return true
        @unknown default:
            return true
        }
    }
    
    func shouldUpdateMessageHidden() {
        notiQueue.async { [weak self] in
            guard let `lastNotiTime` = self?.lastNotiTime else {
                return
            }
            guard Date().timeIntervalSince1970 - lastNotiTime > 10 else {
                return
            }
            DispatchQueue.main.async {
                self?.invokeMeetingVMShouldHidenMessageView(hidden: true)
            }
        }
    }
    
}

extension MeetingVM: NotiObserver {
    func update(infos: [NotiCollector.Info]) {
        shouldUpdateNotis(notis: infos)
    }
}

extension NotiType {
    var notiCollectorNotiType: NotiCollector.Info.NotiType? {
        switch self {
        case .always:
            return .alwayCloseNoti
        case .n10:
            return .maxAttend10
        case .n20:
            return .maxAttend20
        case .n30:
            return .maxAttend30
        case .n40:
            return .maxAttend40
        case .n50:
            return .maxAttend50
        case .n60:
            return .maxAttend60
        case .n70:
            return .maxAttend70
        case .n80:
            return .maxAttend80
        case .n90:
            return .maxAttend90
        case .n100:
            return .maxAttend100
        case .never:
            return nil
        }
    }
}
