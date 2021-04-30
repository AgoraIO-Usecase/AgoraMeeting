//
//  HttpManager+Url.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/21.
//  Copyright © 2021 agora. All rights reserved.
//

#import "HttpManager.h"





NS_ASSUME_NONNULL_BEGIN

@interface HttpManager (Url)
// 创建/加入房间
+ (NSString *)urlAddRoomWitthRoomId:(NSString *)roomId;

/// 离开房间
+ (NSString *)urlLeaveRoomWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 5.3.1.1 用户权限更新
+ (NSString *)urlUserPermissionsWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 全员关闭摄像头/麦克风
+ (NSString *)urlPermissionCLoseAllWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 关闭单人摄像头/麦克风
+ (NSString *)urlPermissionCLoseSingleWitthRoomId:(NSString *)roomId userId:(NSString *)userId;
/// 踢人
+ (NSString *)urlKickoutWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 转交主持人
+ (NSString *)urlTransferHostWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 放弃主持人
+ (NSString *)urlAbandonHostWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 开始录制
+ (NSString *)urlRecordStartWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 关闭录制
+ (NSString *)urlRecordStopWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 接受打开摄像头/麦克风的请求
+ (NSString *)urlPermissionAceptWitthRoomId:(NSString *)roomId
                                     userId:(NSString *)userId
                                  requestId:(NSString *)requestId;

/// 拒绝打开摄像头/麦克风的请求
+ (NSString *)urlPermissionRejectWitthRoomId:(NSString *)roomId
                                      userId:(NSString *)userId
                                   requestId:(NSString *)requestId;

/// 申请成为主持人
+ (NSString *)urlHostApplyWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 请求打开摄像头/麦克风
+ (NSString *)urlPermissionApplyWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 更新会议内的房间信息
+ (NSString *)urlRoomInfoUpdateWithRoomId:(NSString *)roomId;

// 更新房间内用户信息
+ (NSString *)urlUserInfoUpdateWithRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 发起屏幕共享
+ (NSString *)urlShareScreenStartWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 关闭屏幕共享
+ (NSString *)urlShareScreenStopWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 发起白板
+ (NSString *)urlWhiteBoardStartWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 关闭白板
+ (NSString *)urlWhiteBoardStopWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 申请白板互动
+ (NSString *)urlWhiteBoardInteractWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 离开白板互动
+ (NSString *)urlWhiteBoardLeaveWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 结束房间
+ (NSString *)urlEndRoomWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 指定主持人
+ (NSString *)urlAppointHostWitthRoomId:(NSString *)roomId userId:(NSString *)userId;

/// 获取 App 版本配置
+ (NSString *)urlAppVersionWithAppVersion:(NSString *)appVersion;

/// 发送频道消息
+ (NSString *)urlSendMsgWithRoomId:(NSString *)roomId userId:(NSString *)userId;

+ (void)setAppId:(NSString *)appId;

@end

NS_ASSUME_NONNULL_END
