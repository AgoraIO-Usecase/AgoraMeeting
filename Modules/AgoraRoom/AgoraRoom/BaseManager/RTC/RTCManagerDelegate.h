//
//  RTCManagerDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTCManagerDelegate <NSObject>

@optional
- (void)rtcDidJoinedOfUid:(NSUInteger)uid;

- (void)rtcDidOfflineOfUid:(NSUInteger)uid;

- (void)didAudioRouteChanged:(AgoraAudioOutputRouting)routing;

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine lastmileQuality:(AgoraNetworkQuality)quality;
- (void)rtcEngine:(AgoraRtcEngineKit *)engine networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality;
@end

NS_ASSUME_NONNULL_END
