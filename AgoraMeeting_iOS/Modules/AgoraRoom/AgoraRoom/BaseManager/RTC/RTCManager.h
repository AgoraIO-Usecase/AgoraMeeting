//
//  RTCManager.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/4.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
//#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "RTCManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTCManager : NSObject

- (void)initEngineKitWithAppid:(NSString *)appid clientRole:(AgoraClientRole)role dataSourceDelegate:(id<RTCManagerDelegate> _Nullable)rtcDelegate;

- (int)startLastmileProbeTest:(NSString *)appid dataSourceDelegate:(id<RTCManagerDelegate> _Nullable)rtcDelegate;

- (int)joinChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock;

- (int)setupLocalVideo:(AgoraRtcVideoCanvas * _Nullable)local;

- (int)setupRemoteVideo:(AgoraRtcVideoCanvas * _Nonnull)remote;

- (void)setClientRole:(AgoraClientRole)role;

- (int)setRemoteVideoStream:(NSUInteger)uid type:(AgoraVideoStreamType)streamType;

- (int)muteLocalVideoStream:(BOOL)enabled;

- (int)muteLocalAudioStream:(BOOL)enabled;

- (NSString *)getCallId;
- (int)rate:(NSString *)callId rating:(NSInteger)rating description:(NSString *)description;
- (int)switchCamera;

- (void)releaseRTCResources;

@end

NS_ASSUME_NONNULL_END
