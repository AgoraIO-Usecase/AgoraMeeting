//
//  SampleHandler.swift
//  ScreenSharingBroadcast
//
//  Created by ZYP on 2021/3/4.
//  Copyright © 2021 agora. All rights reserved.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {
    let appGroupsString = "group.io.agora.meetingInternal"
    fileprivate var endString = "com.videoconference.shareendbyapp"
    var endByTouchSystemStop = true
    
    override init() {
        super.init()
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let callback: CFNotificationCallback = { (_, observer, name, obj, userInfo) -> Void in
            AgoraUploader.stopBroadcast()
            
            if let observer = observer {
                // Extract pointer to `self` from void pointer:
                let mySelf = Unmanaged<SampleHandler>.fromOpaque(observer).takeUnretainedValue()
                
                // Call instance method:
                
                let str = mySelf.isEn ? "share end by user" : "屏幕分享已结束"
                mySelf.endByTouchSystemStop = false
                let userInfo = [NSLocalizedFailureReasonErrorKey: str]
                let error = NSError(domain: "", code: -1, userInfo: userInfo)
                mySelf.finishBroadcastWithError(error)
            }
        }
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        observer,
                                        callback,
                                        "com.videoconference.exit" as CFString,
                                        nil,
                                        .deliverImmediately)
    }

    deinit {
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                           observer,
                                           CFNotificationName(rawValue: "com.videoconference.exit" as CFString),
                                           nil)
    }
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        
        let userDefault = UserDefaults.init(suiteName: appGroupsString)
        guard let appid = userDefault?.object(forKey: "appid") as? String else {
            return
        }
        
        guard let channelid = userDefault?.object(forKey: "channelid") as? String else {
            return
        }
        
        guard let token = userDefault?.object(forKey: "token") as? String else {
            return
        }
        
        guard let screenid = userDefault?.object(forKey: "screenid") as? String else {
            return
        }
        
        guard let number = UInt(screenid) else {
            return
        }
        
        AgoraUploader.appid = appid
        AgoraUploader.channelid = channelid
        AgoraUploader.screenid = number
        AgoraUploader.token = token
        AgoraUploader.startBroadcast()
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(rawValue: "com.videoconference.sharebegin" as CFString), nil, nil, true);
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        AgoraUploader.stopBroadcast()
        
        if endByTouchSystemStop {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                                 CFNotificationName(rawValue: endString as CFString),
                                                 nil,
                                                 nil,
                                                 true);
        }
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            AgoraUploader.sendVideoBuffer(sampleBuffer)
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
    
    
    func getLanguageType() -> String {
        let def = UserDefaults.standard
        let allLanguages: [String] = def.object(forKey: "AppleLanguages") as! [String]
        let chooseLanguage = allLanguages.first
        return chooseLanguage ?? "en"
    }
    
    var isEn: Bool {
        let lag = getLanguageType()
        return lag == "en-CN"
    }
}
