//
//  AgoraUploader.swift
//  ScreenSharingBroadcast
//
//  Created by SRS on 2020/12/1.
//  Copyright © 2020 agora. All rights reserved.
//

import Foundation
import CoreMedia
import ReplayKit
import AgoraRtcKit

class AgoraUploader {
    private static let videoDimension : CGSize = {
        let screenSize = UIScreen.main.currentMode!.size
        var boundingSize = CGSize(width: 480, height: 640)
        let mW = boundingSize.width / screenSize.width
        let mH = boundingSize.height / screenSize.height
        if( mH < mW ) {
            boundingSize.width = boundingSize.height / screenSize.height * screenSize.width
        }
        else if( mW < mH ) {
            boundingSize.height = boundingSize.width / screenSize.width * screenSize.height
        }
        return boundingSize
    }()

    static var appid: String = ""
    static var channelid: String = ""
    static var token: String = ""
    static var screenid: UInt = 0

    private static let sharedAgoraEngine: AgoraRtcEngineKit = {
        let kit = AgoraRtcEngineKit.sharedEngine(withAppId:appid, delegate: nil)
        kit.setChannelProfile(.liveBroadcasting)
        kit.setClientRole(.broadcaster)
        
        kit.enableVideo()
        kit.disableAudio()
        kit.setExternalVideoSource(true,
                                   useTexture: true,
                                   pushMode: true)
        let videoConfig = AgoraVideoEncoderConfiguration(size: videoDimension,
                                                         frameRate: .fps15,
                                                         bitrate: 0,
                                                         orientationMode: .adaptative)
        kit.setVideoEncoderConfiguration(videoConfig)

        kit.muteAllRemoteVideoStreams(true)
        kit.muteAllRemoteAudioStreams(true)

        return kit
    }()

    static func startBroadcast() {
        sharedAgoraEngine.joinChannel(byToken: token,
                                      channelId: channelid,
                                      info: nil,
                                      uid: screenid,
                                      joinSuccess: nil)
    }

    static func sendVideoBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer)
             else {
            return
        }

        var rotation : Int32 = 0
        if #available(iOSApplicationExtension 11.0, *) {
            if let orientationAttachment = CMGetAttachment(sampleBuffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil) as? NSNumber {
                if let orientation = CGImagePropertyOrientation(rawValue: orientationAttachment.uint32Value) {
                    switch orientation {
                    case .up,    .upMirrored:    rotation = 0
                    case .down,  .downMirrored:  rotation = 180
                    case .left,  .leftMirrored:  rotation = 90
                    case .right, .rightMirrored: rotation = 270
                    default:   break
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }

        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        let frame = AgoraVideoFrame()
        frame.format = 12
        frame.time = time
        frame.textureBuf = videoFrame
        frame.rotation = rotation
        sharedAgoraEngine.pushExternalVideoFrame(frame)
    }

    static func stopBroadcast() {
        sharedAgoraEngine.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }
}
