//
//  HMRequestParams.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/21.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 创建/加入房间 request
@interface HMReqParamsAddRoom : NSObject

// md5(roomName), 32位小写
@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *roomName;
// md5(userName), 32位小写
@property (nonatomic, copy)NSString *userId;
@property (nonatomic, copy)NSString *userName;
@property (nonatomic, copy)NSString *password;
@property (nonatomic, assign)BOOL micAccess;
@property (nonatomic, assign)BOOL cameraAccess;
@property (nonatomic, assign)NSInteger duration;
@property (nonatomic, assign)NSInteger totalPeople;

@end


/// 5.3.1.1 用户权限更新
@interface HMReqParamsUserPermissionsAll : NSObject

@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *userId;
@property (nonatomic, assign)BOOL micAccess;
@property (nonatomic, assign)BOOL cameraAccess;

@end

/// 全员关闭摄像头/麦克风
@interface HMRequestParamsUserPermissionsCloseAll : NSObject
@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *userId;
@property (nonatomic, assign)BOOL micClose;
@property (nonatomic, assign)BOOL cameraClose;
@end



/// 请求打开摄像头/麦克风
typedef HMReqParamsUserPermissionsAll HMRequestParamsPermissionsApply;

/// 关闭单人摄像头/麦克风
@interface HMReqParamsUserPermissionsCloseSingle : NSObject

@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *userId;
@property (nonatomic, assign)BOOL micClose;
@property (nonatomic, assign)BOOL cameraClose;
@property (nonatomic, copy)NSString *targetUserId;

@end

/// 踢人
@interface HMReqParamsKickout : NSObject

@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *userId;
@property (nonatomic, copy)NSString *targetUserId;

@end

/// 转交主持人
typedef HMReqParamsKickout HMReqParamsHostTransfer;
typedef HMReqParamsKickout HMReqParamsAppointHost;


/// 放弃主持人
@interface HMReqParamsHostAbondon : NSObject

@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *userId;

@end


/// 开始录制
typedef HMReqParamsHostAbondon HMReqParamsRecordStart;
/// 关闭录制
typedef HMReqParamsHostAbondon HMReqParamsRecordStop;
/// 申请成为主持人
typedef HMReqParamsHostAbondon HMReqParamsHostApply;
/// 发起屏幕共享
typedef HMReqParamsHostAbondon HMReqParamsScreenShareSatrt;
/// 发起白板
typedef HMReqParamsHostAbondon HMReqParamsParamsWihleBoardStart;
/// 关闭白板
typedef HMReqParamsHostAbondon HMReqParamsWihleBoardStop;
/// 申请白板互动
typedef HMReqParamsHostAbondon HMReqParamsWihleBoardInteract;
/// 离开白板互动
typedef HMReqParamsHostAbondon HMReqParamsWihleBoardLeave;

/// 接受打开摄像头/麦克风的请求
@interface HMReqParamsUserPermissionsRequestAccept : NSObject

@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *userId;
@property (nonatomic, copy)NSString *requestId;
@property (nonatomic, copy)NSString *targetUserId;

@end

/// 拒绝打开摄像头/麦克风的请求
typedef HMReqParamsUserPermissionsRequestAccept HMRequestParamsUserPermissionsRequestReject;

/// 更新会议内的房间信息
@interface HMReqParamsRoomInfoUpdate : NSObject

@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *roomName;
@property (nonatomic, copy)NSString *userId;
@property (nonatomic, copy)NSString *password;

@end

/// 更新房间内用户信息
@interface HMReqParamsUserInfoUpdate : NSObject

@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *userName;
@property (nonatomic, copy)NSString *userId;

@end

/// 关闭屏幕共享
@interface HMReqScreenShareStop : NSObject

@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *streamId;
@property (nonatomic, copy)NSString *userId;

@end

@interface HMReqChannelMsg : NSObject

@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *message;
@property (nonatomic, copy)NSString *userId;

@end



NS_ASSUME_NONNULL_END
