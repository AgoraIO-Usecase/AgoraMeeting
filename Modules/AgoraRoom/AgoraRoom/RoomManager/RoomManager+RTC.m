//
//  RoomManager+RTC.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import "RoomManager+RTC.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
//#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "RoomManagerDelegate.h"
#import <YYModel.h>

@implementation RoomManager (RTC)
- (void)rtcDidJoinedOfUid:(NSUInteger)uid {
    
    
    //    if(self.hostModel && uid == self.hostModel.screenId) {
    //        if([self.delegate respondsToSelector:@selector(didReceivedSignal:)]) {
    //
    //            SignalShareScreenInfoModel *model = [SignalShareScreenInfoModel new];
    //            model.type = 1;
    //            model.screenId = uid;
    //            model.userId = self.hostModel.userId;
    //            self.shareScreenInfoModel = model;
    //
    //            SignalInfoModel *signalInfoModel = [SignalInfoModel new];
    //            signalInfoModel.signalType = SignalValueShareScreen;
    //            [self.delegate didReceivedSignal:signalInfoModel];
    //        }
    //    }
}

- (void)rtcDidOfflineOfUid:(NSUInteger)uid {
    //    if(self.hostModel && uid == self.hostModel.screenId) {
    //        if([self.delegate respondsToSelector:@selector(didReceivedSignal:)]) {
    //
    //            SignalShareScreenInfoModel *model = [SignalShareScreenInfoModel new];
    //            model.type = 0;
    //            model.screenId = uid;
    //            model.userId = self.hostModel.userId;
    //            self.shareScreenInfoModel = model;
    //
    //            SignalInfoModel *signalInfoModel = [SignalInfoModel new];
    //            signalInfoModel.signalType = SignalValueShareScreen;
    //            [self.delegate didReceivedSignal:signalInfoModel];
    //        }
    //    }
}

- (void)didAudioRouteChanged:(AgoraAudioOutputRouting)routing {
    if([self.delegate respondsToSelector:@selector(didAudioRouteChanged:)]) {
        
        AudioOutputRouting _routing = AudioOutputRoutingDefault;
        switch (routing) {
            case AgoraAudioOutputRoutingDefault:
                _routing = AudioOutputRoutingDefault;
                break;
            case AgoraAudioOutputRoutingHeadset:
                _routing = AudioOutputRoutingHeadset;
                break;
            case AgoraAudioOutputRoutingEarpiece:
                _routing = AudioOutputRoutingEarpiece;
                break;
            case AgoraAudioOutputRoutingHeadsetNoMic:
                _routing = AudioOutputRoutingHeadsetNoMic;
                break;
            case AgoraAudioOutputRoutingSpeakerphone:
                _routing = AudioOutputRoutingSpeakerphone;
                break;
            case AgoraAudioOutputRoutingLoudspeaker:
                _routing = AudioOutputRoutingLoudspeaker;
                break;
            case AgoraAudioOutputRoutingHeadsetBluetooth:
                _routing = AudioOutputRoutingHeadsetBluetooth;
                break;
            default:
                break;
        }
        [self.delegate didAudioRouteChanged: _routing];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine lastmileQuality:(AgoraNetworkQuality)quality {
    
    NetworkGrade grade = NetworkGradeUnknown;
    switch (quality) {
        case AgoraNetworkQualityExcellent:
        case AgoraNetworkQualityGood:
            grade = NetworkGradeHigh;
            break;
        case AgoraNetworkQualityPoor:
        case AgoraNetworkQualityBad:
            grade = NetworkGradeMiddle;
            break;
        case AgoraNetworkQualityVBad:
        case AgoraNetworkQualityDown:
            grade = NetworkGradeLow;
            break;
        default:
            break;
    }
    
    if([self.delegate respondsToSelector:@selector(networkLastmileTypeGrade:)]) {
        [self.delegate networkLastmileTypeGrade:grade];
    }
}
- (void)rtcEngine:(AgoraRtcEngineKit *)engine networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality {
    
    NetworkGrade grade = NetworkGradeUnknown;
    
    AgoraNetworkQuality quality = MAX(txQuality, rxQuality);
    switch (quality) {
        case AgoraNetworkQualityExcellent:
        case AgoraNetworkQualityGood:
            grade = NetworkGradeHigh;
            break;
        case AgoraNetworkQualityPoor:
        case AgoraNetworkQualityBad:
            grade = NetworkGradeMiddle;
            break;
        case AgoraNetworkQualityVBad:
        case AgoraNetworkQualityDown:
            grade = NetworkGradeLow;
            break;
        default:
            break;
    }
    
    if([self.delegate respondsToSelector:@selector(networkTypeGrade:uid:)]) {
        [self.delegate networkTypeGrade:grade uid: uid];
    }
}
@end
