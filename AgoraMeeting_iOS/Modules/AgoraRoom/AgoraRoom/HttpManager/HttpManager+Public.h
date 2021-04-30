//
//  HttpManager+Public.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/11.
//  Copyright © 2021 agora. All rights reserved.
//

#import "HttpManager.h"
#import "HMRequestParams.h"

@class HMResponeParamsAddRoom, HMReqParamsAddRoom, HMReqParamsRoomInfoUpdate;
@class HMReqParamsUserInfoUpdate, HMReqParamsUserPermissionsAll, HMReqParamsKickout, HMResponeParamsScreenStart;
@class HMResponeParamsAVAccess, HMRequestParamsUserPermissionsCloseAll, HMResponeParamsAppVersion, HMReqChannelMsg;

typedef void (^HMSuccessBlockAddRoom)(HMResponeParamsAddRoom *_Nonnull);
typedef void (^HMSuccessBlockBool)(BOOL);
typedef void (^HMSuccessBlockVoid)(void);
typedef void (^HMSuccessBlockScreenStart)(HMResponeParamsScreenStart *_Nonnull);
typedef void (^HMSuccessBlockAVAccess)(HMResponeParamsAVAccess *_Nonnull);
typedef void (^HMSuccessBlockAppVersion)(HMResponeParamsAppVersion *_Nonnull);


NS_ASSUME_NONNULL_BEGIN

@interface HttpManager (Public)

/// 5.2.1 创建/加入房间
+ (void)requestAddRoom:(HMReqParamsAddRoom * _Nonnull)request
               success:(HMSuccessBlockAddRoom _Nullable)success
               failure:(HMFailBlock _Nullable)failure;

/// 5.2.2 离开房间
+ (void)requestLeaveRoomWithRoomId:(NSString *)roomId
                            userId:(NSString *)userId
                           success:(HMSuccessBlockVoid _Nullable)success
                           faulure:(HMFailBlock _Nullable)failure;

/// 5.3.3.1. 更新会议内的房间信息
+ (void)requestRoomInfoUpdateWithParam:(HMReqParamsRoomInfoUpdate * _Nonnull)param
                               success:(HMSuccessBlockVoid _Nullable)success
                               failure:(HMFailBlock _Nullable)failure;

/// 5.3.3.2. 更新房间内用户信息
+ (void)requestUserInfoWithParam:(HMReqParamsUserInfoUpdate * _Nonnull)param
                         success:(HMSuccessBlockVoid _Nullable)success
                         failure:(HMFailBlock _Nullable)failure;

/// 5.3.1.1 用户权限更新
+ (void)requestUserPermissionsUpdate:(HMReqParamsUserPermissionsAll * _Nonnull)request
                             success:(HMSuccessBlockVoid _Nullable)success
                             failure:(HMFailBlock _Nullable)failure;

/// 5.3.1.2 全员关闭摄像头/麦克风
+ (void)requestAVCloseAll:(HMRequestParamsUserPermissionsCloseAll * _Nonnull)request
                               success:(HMSuccessBlockVoid _Nullable)success
                               failure:(HMFailBlock _Nullable)failure;

/// 5.3.1.3 踢人
+ (void)requestKickout:(HMReqParamsKickout * _Nonnull)request
               success:(HMSuccessBlockVoid _Nullable)success
               failure:(HMFailBlock _Nullable)failure;

/// 5.3.2.1 申请成为主持人 (没有主持人时，设为主持人)
+ (void)requestHostApplyWithParam:(HMReqParamsHostApply * _Nonnull)param
                          success:(HMSuccessBlockVoid _Nullable)success
                          failure:(HMFailBlock _Nullable)failure;

/// 5.3.1.3 关闭单人摄像头/麦克风
+ (void)reqCloseCameraMicSingle:(HMReqParamsUserPermissionsCloseSingle * _Nonnull)request
                            success:(HMSuccessBlockVoid _Nullable)success
                            failure:(HMFailBlock _Nullable)failure;

/// 5.3.1.6. 放弃主持人
+ (void)requestHostAbandonWithParam:(HMReqParamsHostAbondon * _Nonnull)param
                            success:(HMSuccessBlockVoid _Nullable)success
                            failure:(HMFailBlock _Nullable)failure;

/// 5.2.3.5 发起白板
+ (void)requestWhiteBoardStartWithParam:(HMReqParamsParamsWihleBoardStart * _Nonnull)param
                                success:(HMSuccessBlockVoid _Nullable)success
                                failure:(HMFailBlock _Nullable)failure;

/// 5.3.1.10 接受打开摄像头/麦克风的请求
+ (void)requestUserPermissionsRequestAcceptWitthParam:(HMReqParamsUserPermissionsRequestAccept * _Nonnull)param
                                              success:(HMSuccessBlockVoid _Nullable)success
                                              failure:(HMFailBlock _Nullable)failure;

/// 5.3.1.12. 结束会议
+ (void)requestEndRoomWithRoomId:(NSString *)roomId
                          userId:(NSString *)userId
                         success:(HMSuccessBlockVoid _Nullable)success
                         faulure:(HMFailBlock _Nullable)failure;

/// 5.3.1.6. 指定主持人
+ (void)requestAppointHostWithParam:(HMReqParamsAppointHost *_Nonnull)param
                            success:(HMSuccessBlockVoid _Nullable)success
                            failure:(HMFailBlock _Nullable)failure;

/// 5.3.2.2 请求打开摄像头/麦克风
+ (void)requestPermissionApplyWithParam:(HMRequestParamsPermissionsApply * _Nonnull)param
                                success:(HMSuccessBlockAVAccess _Nullable)success
                                failure:(HMFailBlock _Nullable)failure;


/// 5.3.3.6 关闭白板
+ (void)requestWhiteBoardStopWithParam:(HMReqParamsWihleBoardStop * _Nonnull)param
                               success:(HMSuccessBlockVoid _Nullable)success
                               failure:(HMFailBlock _Nullable)failure;

/// 5.3.3.7 申请白板互动
+ (void)requestWhiteBoardInteractWithParam:(HMReqParamsWihleBoardInteract * _Nonnull)param
                                   success:(HMSuccessBlockVoid _Nullable)success
                                   failure:(HMFailBlock _Nullable)failure;

/// 5.3.3.8. 离开白板互动
+ (void)requestWhiteBoardLeaveWithParam:(HMReqParamsWihleBoardLeave * _Nonnull)param
                                success:(HMSuccessBlockVoid _Nullable)success
                                failure:(HMFailBlock _Nullable)failure;

/// 5.3.3.3. 发起屏幕分享
+ (void)requestScreenShareStartWithParam:(HMReqParamsScreenShareSatrt * _Nonnull)param
                                 success:(HMSuccessBlockScreenStart _Nullable)success
                                 failure:(HMFailBlock _Nullable)failure;

/// 5.3.3.4. 关闭屏幕分享
+ (void)requestScreenShareStopWithParam:(HMReqScreenShareStop * _Nonnull)param
                                success:(HMSuccessBlockVoid _Nullable)success
                                failure:(HMFailBlock _Nullable)failure;

/// 5.4.2. 获取 App 版本配置
+ (void)requestAppVersionWithAppVersion:(NSString * _Nonnull)appVersion
                                success:(HMSuccessBlockAppVersion _Nullable)success
                                failure:(HMFailBlock _Nullable)failure;

/// 5.3.3.10. 发送频道消息
+ (void)requestSendMsg:(HMReqChannelMsg * _Nonnull)param
               success:(HMSuccessBlockVoid _Nullable)success
               faulure:(HMFailBlock _Nullable)failure;

@end

NS_ASSUME_NONNULL_END
