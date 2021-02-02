//
//  SampleHandler.swift
//  ScreenSharingBroadcast
//
//  Created by SRS on 2020/12/1.
//  Copyright © 2020 agora. All rights reserved.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {
    
    fileprivate var endString = "com.videoconference.shareend"
    
    override init() {
        super.init()

        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), observer,
                                        { [self](_, observer, name, _, _) -> Void in

                AgoraUploader.stopBroadcast()

                if let observer = observer {

                    // Extract pointer to `self` from void pointer:
                    let mySelf = Unmanaged<SampleHandler>.fromOpaque(observer).takeUnretainedValue()
                    // Call instance method:
                    let userInfo = [NSLocalizedFailureReasonErrorKey: "屏幕分享已"]
                    let error = NSError(domain: "", code: -1, userInfo: userInfo)
                    if #available(iOS 14.2, *) {
                        mySelf.endString = "com.videoconference.shareendbyapp"
                    }
                    mySelf.finishBroadcastWithError(error)
                }
            },
            "com.videoconference.exit" as CFString,
        nil,
        .deliverImmediately)
    }

    deinit {
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), observer, CFNotificationName(rawValue: "com.videoconference.exit" as CFString), nil)
    }
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        
        let userDefault = UserDefaults.init(suiteName: "group.io.agora.meeting")
        if let appid = userDefault?.object(forKey: "appid") as? String, let channelid = userDefault?.object(forKey: "channelid") as? String, let token = userDefault?.object(forKey: "token") as? String, let screenid = userDefault?.object(forKey: "screenid") as? UInt {

            AgoraUploader.appid = appid
            AgoraUploader.channelid = channelid
            AgoraUploader.screenid = screenid
            AgoraUploader.token = token
            AgoraUploader.startBroadcast()
            
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(rawValue: "com.videoconference.sharebegin" as CFString), nil, nil, true);
        }
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        
        AgoraUploader.stopBroadcast()
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(rawValue: endString as CFString), nil, nil, true);
        endString = "com.videoconference.shareend"
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        DispatchQueue.main.async {
            if sampleBufferType == .video {
                AgoraUploader.sendVideoBuffer(sampleBuffer)
            }
        }
    }
}
