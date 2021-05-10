//
//  NotiVM.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/23.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRoom

protocol NotiVMDelegate: NSObject {
    func notiVMShouldUpdateInfos(infos: [NotiCell.Info], reloadAll: Bool)
    func notiVMShouldShowLoading()
    func notiVMShouldDismissLoading()
    func notiVMDidErrorWithTips(tips: String)
    func notiVMShouldShowNotiSheetVC()
}

class NotiVM: NSObject {
    weak var delegate: NotiVMDelegate?
    
    deinit {
        
    }
    
    override init() {
        super.init()
        NotiCollector.default.delegate2 = self
    }
    
    func start() {
        fetchInfos()
    }
    
    func fetchInfos() {
        let temps = NotiCollector.default.getAll()
        let infos = handleShowTime(infos: temps.map({ $0.toNotiCellInfo }))
        delegate?.notiVMShouldUpdateInfos(infos: infos, reloadAll: true)
    }
    
    func handleShowTime(infos: [NotiCell.Info]) ->  [NotiCell.Info] {
        var temps = infos
        var lastTimeStamp: TimeInterval = 0.0
        for i in 0..<temps.count {
            let shouldShowTime = temps[i].timeStamp - lastTimeStamp > 60
            temps[i].showTime = shouldShowTime
            temps[i].isFirstCell = i == 0
            lastTimeStamp = temps[i].timeStamp
        }
        return temps
    }
    
    func handleInfo(info: NotiCell.Info) {
        let value = info.typeValue
        let notiType = NotiCollector.Info.NotiType(rawValue: value)!
        switch notiType {
        case .applyAudioAction:
            acceptCameraMicOpen(targetUserId: info.targetUserId, requestId: "micAccess", timeStamp: info.timeStamp)
            break
        case .applyVideoAction:
            acceptCameraMicOpen(targetUserId: info.targetUserId, requestId: "cameraAccess", timeStamp: info.timeStamp)
            break
        case .noHostAction:
            setMeAsHost()
            break
        case .cameraNotAuthAction, .micNotAuthAction:
            MeetingVC.showSystemSetting()
            break
        default:
            notiType.isMaxAttendNoti ? delegate?.notiVMShouldShowNotiSheetVC() : nil
            break
        }
    }
    
    func setMeAsHost() {
        let reqParam = HMReqParamsHostAbondon()
        reqParam.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParam.userId = ARConferenceManager.getLocalUser().info.userId
        self.delegate?.notiVMShouldShowLoading()
        HttpManager.requestHostApply(withParam: reqParam) {
            self.delegate?.notiVMShouldDismissLoading()
        } failure: { (error) in
            self.delegate?.notiVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func acceptCameraMicOpen(targetUserId: String, requestId: String, timeStamp: TimeInterval) {
        let parsms = HMReqParamsUserPermissionsRequestAccept()
        parsms.requestId = requestId
        parsms.roomId = ARConferenceManager.getScene().info.sceneId
        parsms.targetUserId = targetUserId
        parsms.userId = ARConferenceManager.getLocalUser().info.userId
        delegate?.notiVMShouldShowLoading()
        HttpManager.requestUserPermissionsRequestAcceptWitthParam(parsms) { [weak self] in
            self?.delegate?.notiVMShouldDismissLoading()
            NotiCollector.default.setActionIsSuccess(timeStamp: timeStamp)
        } failure: { [weak self](error) in
            self?.delegate?.notiVMShouldDismissLoading()
            self?.delegate?.notiVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    
}

extension NotiVM: NotiObserver {
    func update(infos: [NotiCollector.Info]) {
        let temps = handleShowTime(infos: infos.map({ $0.toNotiCellInfo }))
        delegate?.notiVMShouldUpdateInfos(infos: temps, reloadAll: false)
    }
}



extension NotiCollector.Info {
    var toNotiCellInfo: NotiCell.Info {
        let time = Date(timeIntervalSince1970: timeStamp).timeString3
        
        if hasAction, let timeCount = timeCount, !success {
            let msg = targetUserName != nil ? "\(targetUserName!)-\(tipsMsg)" : tipsMsg
            return NotiCell.Info(msg: msg,
                                 buttonTitle: buttonTitle,
                                 buttonEnable: buttonEnable,
                                 timeCount: timeCount,
                                 time: time,
                                 typeValue: notiType.rawValue,
                                 targetUserId: targetUserId ?? "",
                                 timeStamp: timeStamp)
        }
        if hasAction, let timeCount = timeCount, success {
            let msg = targetUserName != nil ? "\(targetUserName!)-\(tipsMsg)" : tipsMsg
            return NotiCell.Info(msg: msg,
                                 buttonTitle: successButtonTitle,
                                 buttonEnable: false,
                                 timeCount: timeCount,
                                 time: time,
                                 typeValue: notiType.rawValue,
                                 targetUserId: targetUserId ?? "",
                                 timeStamp: timeStamp)
        }
        if hasAction {
            let msg = tipsMsg
            return NotiCell.Info(msg: msg,
                                 buttonTitle: buttonTitle,
                                 buttonEnable: true,
                                 time: time,
                                 typeValue: notiType.rawValue,
                                 timeStamp: timeStamp)
        }
        
        let msg = targetUserName != nil ? "\(targetUserName!) \(tipsMsg)" : tipsMsg
        return NotiCell.Info(msg: msg, time: time, typeValue: notiType.rawValue, timeStamp: timeStamp)
    }
}
