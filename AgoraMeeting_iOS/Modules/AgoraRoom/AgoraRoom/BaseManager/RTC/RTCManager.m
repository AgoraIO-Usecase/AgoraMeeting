//
//  RTCManager.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/4.
//  Copyright © 2020 agora. All rights reserved.
//

#import "RTCManager.h"
#import "LogManager.h"

@interface RTCManager()<AgoraRtcEngineDelegate>

@property (nonatomic, weak) id<RTCManagerDelegate> delegate;
@property (nonatomic, strong) AgoraRtcEngineKit * _Nullable rtcEngineKit;
@property (nonatomic, assign) AgoraClientRole currentRole;

@property (nonatomic, assign) BOOL frontCamera;

@end

@implementation RTCManager

- (void)initEngineKitWithAppid:(NSString *)appid clientRole:(AgoraClientRole)role dataSourceDelegate:(id<RTCManagerDelegate> _Nullable)rtcDelegate {
    
    AgoraLogInfo(@"init rtcEngineKit appid:%@", appid);
    
    self.delegate = rtcDelegate;
    self.frontCamera = YES;
    
    if(self.rtcEngineKit == nil){
        self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:appid delegate:self];
    }
    NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/Agora/agoraRTC.log"];
    [self.rtcEngineKit disableLastmileTest];
    [self.rtcEngineKit setLogFile:logFilePath];
    [self.rtcEngineKit setLogFileSize:512];
    [self.rtcEngineKit setLogFilter:AgoraLogFilterInfo];
    
    [self.rtcEngineKit setChannelProfile: AgoraChannelProfileLiveBroadcasting];
    AgoraVideoEncoderConfiguration *configuration = [AgoraVideoEncoderConfiguration new];
    configuration.dimensions = AgoraVideoDimension360x360;
    configuration.frameRate = 15;
    configuration.bitrate = AgoraVideoBitrateStandard;
    configuration.orientationMode = AgoraVideoOutputOrientationModeFixedLandscape;
    [self.rtcEngineKit setVideoEncoderConfiguration:configuration];
    
    [self.rtcEngineKit enableVideo];
    [self.rtcEngineKit enableWebSdkInteroperability:YES];
    [self.rtcEngineKit enableDualStreamMode:YES];
    [self setClientRole: role];

    if(role == AgoraClientRoleBroadcaster){
        [self.rtcEngineKit startPreview];
    }
    
    [self.rtcEngineKit setParameters:@"{\"che.audio.specify.codec\":\"OPUSFB\"}"];
    [self.rtcEngineKit setAudioProfile:AgoraAudioProfileDefault scenario:AgoraAudioScenarioGameStreaming];
}

- (int)startLastmileProbeTest:(NSString *)appid dataSourceDelegate:(id<RTCManagerDelegate> _Nullable)rtcDelegate {
    
    if(self.rtcEngineKit == nil){
        self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:appid delegate:self];
    }
    self.delegate = rtcDelegate;
    return [self.rtcEngineKit enableLastmileTest];
}

- (int)joinChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock {
    AgoraLogInfo(@"join rtc token:%@ channel:%@", token, channelId);
    return [self.rtcEngineKit joinChannelByToken:token channelId:channelId info:info uid:uid joinSuccess:joinSuccessBlock];
}

- (int)setupLocalVideo:(AgoraRtcVideoCanvas * _Nullable)local {
    return [self.rtcEngineKit setupLocalVideo:local];
}
- (int)setupRemoteVideo:(AgoraRtcVideoCanvas * _Nonnull)remote {
    return [self.rtcEngineKit setupRemoteVideo:remote];
}

- (void)setClientRole:(AgoraClientRole)role {

    if(self.currentRole == role) {
        return;
    }
    
    if(role == AgoraClientRoleAudience){
        [self.rtcEngineKit setClientRole:role];
        AgoraLogInfo(@"set role audience");
    } else if(role == AgoraClientRoleBroadcaster){
        [self.rtcEngineKit setClientRole:role];
        AgoraLogInfo(@"set role broadcaster");
    }
    self.currentRole = role;
}

- (int)setRemoteVideoStream:(NSUInteger)uid type:(AgoraVideoStreamType)streamType {
    return [self.rtcEngineKit setRemoteVideoStream:uid type:streamType];
}

- (int)muteLocalVideoStream:(BOOL)enabled {
    AgoraLogInfo(@"muteRTCLocalVideo: %d", enabled);
    return [self.rtcEngineKit muteLocalVideoStream:enabled];
}

- (int)muteLocalAudioStream:(BOOL)enabled {
    AgoraLogInfo(@"muteRTCLocalAudio: %d", enabled);
    return [self.rtcEngineKit muteLocalAudioStream:enabled];
}

- (NSString *)getCallId {
    NSString *callid = [self.rtcEngineKit getCallId];
    AgoraLogInfo(@"getCallId: %@", callid);
    return callid;
}
- (int)rate:(NSString *)callId rating:(NSInteger)rating description:(NSString *)description {
    AgoraLogInfo(@"rate callid: %@, rating:%ld, description:%@", callId, (long)rating, description);
    int rate = [self.rtcEngineKit rate:callId rating:rating description:description];
    return rate;
}

- (int)switchCamera {
    self.frontCamera = !self.frontCamera;
    AgoraLogInfo(@"switch camera: %d", self.frontCamera);
    return [self.rtcEngineKit switchCamera];
}

- (void)releaseRTCResources {
    AgoraLogInfo(@"releaseRTCResources");
    [self.rtcEngineKit leaveChannel:nil];
    [self.rtcEngineKit stopPreview];
}

-(void)dealloc {
    [self releaseRTCResources];
}

#pragma mark AgoraRtcEngineDelegate
- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    
    AgoraLogInfo(@"didJoinedOfUid: %lu", (unsigned long)uid);
    if([self.delegate respondsToSelector:@selector(rtcDidJoinedOfUid:)]) {
        [self.delegate rtcDidJoinedOfUid:uid];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    
    AgoraLogInfo(@"didOfflineOfUid: %lu", (unsigned long)uid);
    if([self.delegate respondsToSelector:@selector(rtcDidOfflineOfUid:)]) {
        [self.delegate rtcDidOfflineOfUid:uid];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didAudioRouteChanged:(AgoraAudioOutputRouting)routing {
    if([self.delegate respondsToSelector:@selector(didAudioRouteChanged:)]) {
        [self.delegate didAudioRouteChanged:routing];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine lastmileQuality:(AgoraNetworkQuality)quality {
    if([self.delegate respondsToSelector:@selector(rtcEngine:lastmileQuality:)]) {
        [self.delegate rtcEngine:engine lastmileQuality:quality];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality {

    if([self.delegate respondsToSelector:@selector(rtcEngine:networkQuality:txQuality:rxQuality:)]) {
        [self.delegate rtcEngine:engine networkQuality:uid txQuality:txQuality rxQuality:rxQuality];
    }
}
@end
