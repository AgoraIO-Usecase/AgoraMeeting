//
//  NotiCollector.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/21.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte

protocol NotiObserver: NSObject {
    func update(infos: [NotiCollector.Info])
}

class NotiCollector: NSObject {
    static let `default` = NotiCollector()
    var mustUpdate = false
    private var messages = [Info]()
    private let timerSource = NotiTimerSource()
    private var successQueue = [TimeInterval]()
    
    /// should be set as observers mode
    weak var delegate1: NotiObserver?
    weak var delegate2: NotiObserver?
    
    override init() {
        super.init()
        timerSource.delegate = self
    }
    
    func clean() {
        messages = [Info]()
        timerSource.stop()
    }
    
    func add(infos: [Info]) {
        messages.append(contentsOf: infos)
        update()
        runTimeIfNeeded()
    }
    
    func runTimeIfNeeded() {
        let needTimer = messages.contains { (info) -> Bool in
            return (info.notiType == .applyAudioAction || info.notiType == .applyVideoAction) && info.timeCount ?? 0 > 0
        }
        if needTimer {
            if timerSource.isStarting == false { timerSource.start() }
        }
        else {
            timerSource.stop()
        }
    }
    
    func getAll() -> [Info] {
        return messages
    }
    
    func update() {
        if Thread.isMainThread {
            delegate1?.update(infos: messages)
            delegate2?.update(infos: messages)
            return
        }
        
        DispatchQueue.main.sync {
            delegate1?.update(infos: messages)
            delegate2?.update(infos: messages)
        }
    }
    
    func setActionIsSuccess(timeStamp: TimeInterval) {
        if timerSource.isStarting {
            successQueue.append(timeStamp)
            return
        }
        
        let count = messages.count
        for i in 0..<count {
            messages[i].updateCount()
        }
    }
    
}

extension NotiCollector: NotiTimerSourceDelegate {
    func notiTimerSourceDidCome() {
        let needUpdate = messages.contains { (info) -> Bool in
            return (info.notiType == .applyAudioAction || info.notiType == .applyVideoAction) && info.timeCount ?? 0 > 0
        }
        if needUpdate {
            let count = messages.count
            for i in 0..<count {
                messages[i].updateCount()
                for time in successQueue {
                    messages[i].updateSuccess(timeStamp: time)
                }
                if successQueue.count > 0 {
                    mustUpdate = true
                }
            }
        }
        update()
    }
}

extension NotiCollector {
    struct Info {
        let notiType: NotiType
        let timeStamp: TimeInterval
        let targetUserId: String?
        let targetUserName: String?
        let tipsMsg: String
        var timeCount: TimeInterval?
        let hasAction: Bool
        let buttonTitle: String
        let successButtonTitle: String
        var buttonEnable = true
        var success = false
        
        enum NotiType: Int {
            case enterRoom
            case leaveRoom
            case requestHostFail
            case roomEnd
            case beKickout
            case newHost
            
            case closeAllMic
            case closeAllCamera
            case closeSingleMic
            case closeSingleCamera
            case audioOpenShouldApply
            case videoOpenShouldApply
            case audioOpenFree
            case videoOpenFree
            case boardStart
            case boardEnd
            case boardInteract
            case screenShareStart
            case screenShareend
            
            /// with action
            case applyAudioAction
            case applyVideoAction
            case cameraNotAuthAction
            case micNotAuthAction
            case noHostAction
            
            case alwayCloseNoti
            case maxAttend10
            case maxAttend20
            case maxAttend30
            case maxAttend40
            case maxAttend50
            case maxAttend60
            case maxAttend70
            case maxAttend80
            case maxAttend90
            case maxAttend100
            
            var isMaxAttendNoti: Bool {
                switch self {
                case .alwayCloseNoti, .maxAttend10, .maxAttend20,
                     .maxAttend30, .maxAttend40, .maxAttend50,
                     .maxAttend60, .maxAttend70, .maxAttend80,
                     .maxAttend90, .maxAttend100:
                    return true
                default:
                    return false
                }
            }
            
        }
        
        /// init for type which is no Action
        init(notiType: NotiType, tipsMsg: String, targetUserName: String?, timeStamp: TimeInterval = Date().timeIntervalSince1970) {
            self.notiType = notiType
            self.timeStamp = timeStamp
            self.targetUserId = nil
            self.targetUserName = targetUserName
            self.tipsMsg = tipsMsg
            self.hasAction = false
            self.buttonTitle = ""
            self.successButtonTitle = ""
        }
        
        /// init for type which has Action
        init(notiType: NotiType,
             tipsMsg: String,
             targetUserName: String?,
             targetUserId: String?,
             timeCount: TimeInterval?,
             buttonTitle: String,
             timeStamp: TimeInterval = Date().timeIntervalSince1970,
             successButtonTitle: String) {
            self.notiType = notiType
            self.timeStamp = timeStamp
            self.targetUserId = targetUserId
            self.targetUserName = targetUserName
            self.tipsMsg = tipsMsg
            self.timeCount = timeCount
            self.hasAction = true
            self.buttonTitle = buttonTitle
            self.successButtonTitle = successButtonTitle
        }
        
        mutating func updateCount() {
            if (timeCount != nil) {
                if timeCount! > 0 {
                    timeCount! -= 1
                    if timeCount == 0 {
                        buttonEnable = false
                    }
                }
            }
        }
        
        mutating func updateSuccess(timeStamp: TimeInterval) {
            if self.timeStamp == timeStamp {
                self.success = true
                self.timeCount = 0
                self.buttonEnable = false
            }
        }
    }
}
