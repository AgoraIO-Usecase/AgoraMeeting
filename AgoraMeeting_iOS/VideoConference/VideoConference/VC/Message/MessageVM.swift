//
//  MessageVM.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/24.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte
import AgoraRoom

protocol MessageVMDelegate: NSObject {
    func messageVMShouldUpdateInfos(infos: [MessageVM.Info])
    func messageVMShouldTips(text: String)
}

class MessageVM: NSObject {
    typealias Info = MessageCollector.Info
    var userInfos = [MeetingVM.Info]()
    var datas = [Info]()
    
    weak var delegate: MessageVMDelegate?
    
    override init() {
        super.init()
        setup()
        conmonInit()
    }
    
    func start() {
        updateInfos()
    }
    
    func setup() {
        datas = MessageCollector.default.getAll()
    }
    
    func conmonInit() {
        MessageCollector.default.delegate2 = self
    }
    
    func updateInfos() {
        var temps = datas
        /// decide to show time or not
        var lastTimeStamp: TimeInterval = 0.0
        var lastIsSelf: Bool?
        for i in 0..<temps.count {
            if let `lastIsSelf` = lastIsSelf {
                let isSamePeer = temps[i].isSelfSend == lastIsSelf
                let shouldShowTime = temps[i].timestamp - lastTimeStamp > 60
                temps[i].showTime = isSamePeer && shouldShowTime
            }
            else {
                temps[i].showTime = true
            }
            lastIsSelf = temps[i].isSelfSend
            lastTimeStamp = temps[i].timestamp
        }
        
        delegate?.messageVMShouldUpdateInfos(infos: temps)
    }
    
    func updateUserInfo(userInfos: [MeetingVM.Info]) {
        self.userInfos = userInfos
        updateInfos()
    }
    
    func send(text: String) {
        let localUser = ARConferenceManager.getLocalUser()
        let scene = ARConferenceManager.getScene()
        let localUserId = localUser.info.userId
        let localUserName = localUser.info.userName
        let msg = AgoraRteMessage(message: text)
        let timestamp = msg.timestamp
        var info = Info(userId: localUserId,
                        userName: localUserName,
                        message: text,
                        timestamp: timestamp,
                        isSelfSend: true,
                        type: .chat,
                        status: .sending)
        MessageCollector.default.add(message: info)
        
        let param = HMReqChannelMsg()
        param.message = text
        param.userId = localUserId
        param.roomId = scene.info.sceneId
        HttpManager.requestSend(param) { [weak self]() in
            Log.info(text: "success", tag: "send msg")
            guard let `self` = self else { return }
            info.setStatus(status: .success)
            self.updateLocalSendSource(info: info)
        } faulure: {  [weak self](error) in
            Log.errorText(text: error.localizedDescription, tag: "send msg")
            guard let `self` = self else { return }
            info.setStatus(status: .fail)
            self.updateLocalSendSource(info: info)
            self.delegate?.messageVMShouldTips(text: "msg_t7")
        }
    }
    
    func updateLocalSendSource(info: Info) {
        MessageCollector.default.update(message: info)
    }
    
    func retry(info: Info) {
        var temp = info
        temp.setStatus(status: .sending)
        let msg = AgoraRteMessage(message: temp.message)
        updateLocalSendSourceByRetrySending(info: temp, msg: msg)
        ARConferenceManager.getLocalUser().sendSceneMessage(toAllRemoteUsers: msg) {
            Log.info(text: "success", tag: "retry send msg")
            temp.setStatus(status: .success)
            self.updateLocalSendSourceByRetryRespon(info: temp, msg: msg)
        } fail: { (error) in
            Log.errorText(text: error.description, tag: "retry send msg")
            temp.setStatus(status: .fail)
            self.updateLocalSendSourceByRetryRespon(info: temp, msg: msg)
            self.delegate?.messageVMShouldTips(text: "msg_t7")
        }
    }
    
    func updateLocalSendSourceByRetrySending(info: Info, msg: AgoraRteMessage) {
        MessageCollector.default.update(message: info)
    }
    
    func updateLocalSendSourceByRetryRespon(info: Info, msg: AgoraRteMessage) {
        MessageCollector.default.update(message: info)
    }
}


extension MessageVM: MessageObserver {
    func update(newValue: [MessageCollector.Info]) {
        datas = newValue
        updateInfos()
    }
    
    func updateUnReadCount(count: Int) {}
}


