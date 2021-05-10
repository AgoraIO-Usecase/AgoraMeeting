//
//  ARConferenceManager.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/7.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARBlockDefine.h"
@class AgoraRteEngine, AgoraRteScene, AgoraRteEngineConfig, AgoraRteLocalUser, HMResponeParamsAddRoom, UIView;



@class ARConferenceEntryParams;

NS_ASSUME_NONNULL_BEGIN

@interface ARConferenceManager : NSObject

+ (void)entryRoomWithParams:(ARConferenceEntryParams *)params
                    successBlock:(ARVoidBlock)successBlock
                  failBlock:(ARErrorBlock)failBlock;

+ (AgoraRteEngine *)getRteEngine;
+ (AgoraRteScene *)getScene;
+ (ARConferenceEntryParams *)getEntryParams;
+ (AgoraRteLocalUser *)getLocalUser;
+ (HMResponeParamsAddRoom *)getAddRoomResp;
+ (void)cleanData;
+ (void)renderLocalView:(UIView *)view;
+ (void)renderRemoteView:(UIView *)view streamId:(NSString *)streamId;
+ (BOOL)currentRoleIsHost;
+ (BOOL)isMeFromUserId:(NSString *)userId;
+ (AgoraRteEngineConfig *)setDefaultHost:(AgoraRteEngineConfig *)config;

@end

NS_ASSUME_NONNULL_END
