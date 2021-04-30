//
//  ARDataManager.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/7.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ARConferenceEntryParams;
@class AgoraRteEngine, AgoraRteScene;
@class AgoraRteLocalUser, HMResponeParamsAddRoom;

NS_ASSUME_NONNULL_BEGIN

@interface ARDataManager : NSObject

+ (instancetype)share;

@property (nonatomic, strong)ARConferenceEntryParams * _Nullable entryParams;
@property (nonatomic, strong)AgoraRteEngine * _Nullable rteEngine;
@property (nonatomic, strong)AgoraRteScene * _Nullable scene;
@property (nonatomic, strong)AgoraRteLocalUser * _Nullable localuser;
@property (nonatomic, strong)HMResponeParamsAddRoom * _Nullable addRoomResp;

@property (nonatomic, strong)dispatch_queue_t requsetQueue;


@end

NS_ASSUME_NONNULL_END
