//
//  HMResponeParams.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/21.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 创建/加入房间 respone
@interface HMResponeParamsAddRoom : NSObject

@property (nonatomic, copy)NSString *streamId;
@property (nonatomic, copy)NSString *userRole;
@property (nonatomic, assign)NSInteger startTime;
@end


@interface HMResponeParamsBool : NSObject

@property (nonatomic, assign)BOOL ok;

@end

/// 发起屏幕分享
@interface HMResponeParamsScreenStart : NSObject

@property (nonatomic, copy)NSString *rtcToken;

@end

/// 请求打开摄像头/麦克风
@interface HMResponeParamsAVAccess : NSObject

@property (nonatomic, strong)NSString *requestId;

@end

/// 离开房间
typedef HMResponeParamsBool HMResponeParamsLeaveRoom;
/// 其他
typedef HMResponeParamsBool HMResponeParamsUserPermissions;

@interface HMResponeParamsAppVersion : NSObject
/// 是否强制更新 0 不更新 1推荐更新 2强制更新
@property (nonatomic, assign) NSInteger forcedUpgrade;
@property (nonatomic, assign) NSString *latestVersion;

@end


NS_ASSUME_NONNULL_END
