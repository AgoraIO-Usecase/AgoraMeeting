//
//  ARConferenceManager.m
//  AgoraRoom
//
//  Created by ZYP on 2021/1/7.
//  Copyright © 2021 agora. All rights reserved.
//

#import "ARConferenceManager.h"
#import "ARConferenceEntryParams.h"
#import "ARBlockDefine.h"
#import "ARDataManager.h"
#import <AgoraRte/AgoraRteEngine.h>
#import "AgoraRteEngineConfig+Extension.h"
#import "ARError.h"
#import <AgoraRte/AgoraRteObjects.h>
#import "HttpManager+Public.h"
#import "HMRequestParams+Category.h"
#import "HMResponeParams.h"
#import "LogManager.h"
#import <UIKit/UIKit.h>

@implementation ARConferenceManager

/// jion or create a room
+ (void)entryRoomWithParams:(ARConferenceEntryParams *)params
               successBlock:(ARVoidBlock)successBlock
                  failBlock:(ARErrorBlock)failBlock {
    dispatch_queue_t queue = ARDataManager.share.requsetQueue;
    dispatch_async(queue, ^{
        dispatch_semaphore_t semp = dispatch_semaphore_create(0);
        __block NSError *error;
        __block HMResponeParamsAddRoom *resp;
        __block AgoraRteEngine *rteEngine;
        __block AgoraRteLocalUser *localUser;
        
        // 1. server join

        [LogManager info:@"&&&start requestAddRoom"];
        HMReqParamsAddRoom *reqParams = [HMReqParamsAddRoom instanceWithEntryParams:params];
        [HttpManager requestAddRoom:reqParams success:^(HMResponeParamsAddRoom *addRoomResp) {
            resp = addRoomResp;
            [LogManager info:@"&&&end requestAddRoom: success"];
            dispatch_semaphore_signal(semp);
        } failure:^(NSError *e) {
            [LogManager info:@"&&&end requestAddRoom: error"];
            error = e;
            dispatch_semaphore_signal(semp);
        }];
        dispatch_semaphore_wait(semp, -1);
        if(error != nil) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                failBlock(error);
            });
            return;
        }
        
        // 2. create RteEngine
        ARDataManager.share.entryParams = params;
        AgoraRteEngineConfig *config = [AgoraRteEngineConfig instanceWithEntryparams:params];
#if DEBUG
        config.logConsolePrintType = AgoraConsolePrintTypeAll;
#else
        config.logConsolePrintType = AgoraConsolePrintTypeDebug;
#endif
        [ARConferenceManager setDefaultHost:config];
        [LogManager info:@"&&&start createWithConfig"];
        [AgoraRteEngine createWithConfig:config success:^(AgoraRteEngine *engine) {
            [LogManager info:@"createWithConfig success"];
            rteEngine = engine;
            dispatch_semaphore_signal(semp);
        } fail:^(AgoraRteError *e) {
            [LogManager info:@"&&&createWithConfig error"];
            ARError *arError = [ARError errorWithRteError:e];
            error = arError;
            dispatch_semaphore_signal(semp);
        }];
        dispatch_semaphore_wait(semp, -1);
        if(error != nil) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                failBlock(error);
            });
            return;
        }
        
        AgoraRteAudioEncoderConfig *audioConfig = [[AgoraRteAudioEncoderConfig alloc] initWithProfile:AgoraRteAudioProfileDefault scenario:AgoraRteAudioScenarioMeeting];
        [[[ARDataManager.share.rteEngine getAgoraMediaControl] createMicphoneAudioTrack] setAudioEncoderConfig:audioConfig];
        
        AgoraRteVideoEncoderConfig *videoConfig = [[AgoraRteVideoEncoderConfig alloc] initWithDimension:CGSizeMake(640, 480)
                                                                                              frameRate:15
                                                                                                bitrate:0
                                                                                        orientationMode:AgoraRteVideoOutputOrientationModeAdaptative
                                                                                  degradationPreference:AgoraRteDegradationPreferenceQuality];
        [[[ARDataManager.share.rteEngine getAgoraMediaControl] createCameraVideoTrack] setVideoEncoderConfig:videoConfig];
        
        // 3. rte join
        AgoraRteSceneConfig *sceneConfig = [[AgoraRteSceneConfig alloc] initWithSceneId:params.roomUuid];
        AgoraRteScene *scene = [rteEngine createAgoraRteScene:sceneConfig];
        
        AgoraRteSceneJoinOptions *joinOptions = [[AgoraRteSceneJoinOptions alloc] initWithUserName:params.userName userRole:resp.userRole];
        [LogManager info:@"&&&start joinWithOptions"];
        [scene joinWithOptions:joinOptions success:^(AgoraRteLocalUser *user) {
            [LogManager info:@"&&&joinWithOptions success"];
            localUser = user;
            dispatch_semaphore_signal(semp);
        } fail:^(AgoraRteError *e) {
            [LogManager info:@"&&&joinWithOptions error"];
            ARError *arError = [ARError errorWithRteError:e];
            error = arError;
            dispatch_semaphore_signal(semp);
        }];
        dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 6);
        dispatch_semaphore_wait(semp, duration);
        if(error != nil) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                failBlock(error);
            });
            return;
        }
        if(localUser == nil) {/** invoke when rte join time out **/
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSError *err = [NSError errorWithDomain:@"ARConferenceManager.entryRoomWithParams"
                                                   code:-1000 userInfo:@{NSLocalizedDescriptionKey : @"加入失败"}];
                failBlock(err);
            });
            return;
        }
        [LogManager info:@"&&&joinWithOptions success 2"];
        
        if (localUser != nil) { /** enableDualStreamMode  **/
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [localUser performSelector:NSSelectorFromString(@"enableDualStreamMode:")
                            withObject:[NSNumber numberWithBool:YES]];
#pragma clang diagnostic pop
        }
        
        // 5. save
        dispatch_sync(dispatch_get_main_queue(), ^{
            [LogManager info:@"&&&joinWithOptions success 3"];
            ARDataManager.share.rteEngine = rteEngine;
            ARDataManager.share.scene = scene;
            ARDataManager.share.localuser = localUser;
            ARDataManager.share.entryParams = params;
            ARDataManager.share.addRoomResp = resp;
            successBlock();
        });
    });
}

+ (AgoraRteEngineConfig *)setDefaultHost:(AgoraRteEngineConfig *)config {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        /// rte切换到开发环境
        SEL func = NSSelectorFromString(@"updateServerHost:");
        NSString *host = @"http://api-solutions-dev.bj2.agoralab.co/scene";
        [config performSelector:func withObject:host];
#pragma clang diagnostic pop
    return config;
}

+ (void)renderLocalView:(UIView *)view {
    [[[ARDataManager.share.rteEngine getAgoraMediaControl] createCameraVideoTrack] start];
    [[[ARDataManager.share.rteEngine getAgoraMediaControl] createCameraVideoTrack] setView:view];
}


+ (void)renderRemoteView:(UIView *)view streamId:(NSString *)streamId {
    AgoraRteRenderConfig *config = [[AgoraRteRenderConfig alloc] initWithRenderMode:AgoraRteRenderModeHidden];
    [ARDataManager.share.localuser renderRemoteStream:streamId onView:view renderConfig:config];
}

+ (AgoraRteEngine *)getRteEngine {
    return ARDataManager.share.rteEngine;
}

+ (AgoraRteScene *)getScene {
    return ARDataManager.share.scene;
}

+ (ARConferenceEntryParams *)getEntryParams {
    return ARDataManager.share.entryParams;
}

+ (AgoraRteLocalUser *)getLocalUser {
    return ARDataManager.share.localuser;
}

+ (HMResponeParamsAddRoom *)getAddRoomResp {
    return ARDataManager.share.addRoomResp;
}

+ (void)cleanData {
    ARDataManager.share.rteEngine = nil;
    ARDataManager.share.scene = nil;
    ARDataManager.share.entryParams = nil;
    ARDataManager.share.localuser = nil;
    ARDataManager.share.addRoomResp = nil;
}

+ (BOOL)currentRoleIsHost {
    return [[ARConferenceManager getLocalUser].info.userRole isEqualToString:@"host"];
}

+ (BOOL)isMeFromUserId:(NSString *)userId {
    return  [[ARConferenceManager getLocalUser].info.userId isEqualToString:userId];
}



@end
