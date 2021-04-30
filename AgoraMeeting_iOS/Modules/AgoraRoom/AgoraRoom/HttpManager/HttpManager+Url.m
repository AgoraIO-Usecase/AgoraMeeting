//
//  HttpManager+Url.m
//  AgoraRoom
//
//  Created by ZYP on 2021/1/21.
//  Copyright © 2021 agora. All rights reserved.
//

#import "HttpManager+Url.h"

static NSString *_appId = @"";

@implementation HttpManager (Url)

+ (NSString *)baseUrlString {
    return [NSString stringWithFormat:@"https://api.agora.io/scenario/meeting/apps/%@/v2/", _appId];
}

+ (NSString *)baseUrlStringWithNoAppId {
    return [NSString stringWithFormat:@"https://api.agora.io/scenario/meeting/v2/"];
}

/// 创建/加入房间
+ (NSString *)urlAddRoomWitthRoomId:(NSString *)roomId {
    return [NSString stringWithFormat:@"%@rooms/%@/join", [self baseUrlString], roomId];
}

/// 离开房间
+ (NSString *)urlLeaveRoomWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/leave", [self baseUrlString], roomId, userId];
}

/// 5.3.1.1 用户权限更新
+ (NSString *)urlUserPermissionsWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/userPermissions", [self baseUrlString], roomId, userId];
}

/// 全员关闭摄像头/麦克风
+ (NSString *)urlPermissionCLoseAllWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/userPermissions/closeAll", [self baseUrlString], roomId, userId];
}

/// 关闭单人摄像头/麦克风
+ (NSString *)urlPermissionCLoseSingleWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/userPermissions/close", [self baseUrlString], roomId, userId];
}

/// 踢人
+ (NSString *)urlKickoutWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/kickOut", [self baseUrlString], roomId, userId];
}

/// 转交主持人
+ (NSString *)urlTransferHostWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/hosts/transfer", [self baseUrlString], roomId, userId];
}

/// 放弃主持人
+ (NSString *)urlAbandonHostWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/hosts/abandon", [self baseUrlString], roomId, userId];
}

/// 开始录制
+ (NSString *)urlRecordStartWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/record/start", [self baseUrlString], roomId, userId];
}

/// 关闭录制
+ (NSString *)urlRecordStopWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/record/stop", [self baseUrlString], roomId, userId];
}

/// 接受打开摄像头/麦克风的请求
+ (NSString *)urlPermissionAceptWitthRoomId:(NSString *)roomId
                                     userId:(NSString *)userId
                                  requestId:(NSString *)requestId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/requests/%@/accept", [self baseUrlString], roomId, userId, requestId];
}

/// 拒绝打开摄像头/麦克风的请求
+ (NSString *)urlPermissionRejectWitthRoomId:(NSString *)roomId
                                     userId:(NSString *)userId
                                  requestId:(NSString *)requestId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/requests/%@/reject", [self baseUrlString], roomId, userId, requestId];
}

/// 申请成为主持人
+ (NSString *)urlHostApplyWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/hosts/apply", [self baseUrlString], roomId, userId];
}

/// 请求打开摄像头/麦克风
+ (NSString *)urlPermissionApplyWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/requests", [self baseUrlString], roomId, userId];
}

/// 更新会议内的房间信息
+ (NSString *)urlRoomInfoUpdateWithRoomId:(NSString *)roomId {
    return [NSString stringWithFormat:@"%@rooms/%@/", [self baseUrlString], roomId];
}

/// 更新房间内用户信息
+ (NSString *)urlUserInfoUpdateWithRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@", [self baseUrlString], roomId, userId];
}

/// 发起屏幕共享
+ (NSString *)urlShareScreenStartWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/screen/start", [self baseUrlString], roomId, userId];
}

/// 关闭屏幕共享
+ (NSString *)urlShareScreenStopWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/screen/stop", [self baseUrlString], roomId, userId];
}

/// 发起白板
+ (NSString *)urlWhiteBoardStartWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/board/start", [self baseUrlString], roomId, userId];
}

/// 关闭白板
+ (NSString *)urlWhiteBoardStopWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/board/stop", [self baseUrlString], roomId, userId];
}

/// 申请白板互动
+ (NSString *)urlWhiteBoardInteractWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/board/interact", [self baseUrlString], roomId, userId];
}

/// 离开白板互动
+ (NSString *)urlWhiteBoardLeaveWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/board/leave", [self baseUrlString], roomId, userId];
}

/// 结束房间
+ (NSString *)urlEndRoomWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/endRoom", [self baseUrlString], roomId, userId];
}

/// 指定主持人
+ (NSString *)urlAppointHostWitthRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/hosts/appoint", [self baseUrlString], roomId, userId];
}

/// 获取 App 版本配置
+ (NSString *)urlAppVersionWithAppVersion:(NSString *)appVersion {
    return [NSString stringWithFormat:@"%@appVersion?osType=1&terminalType=1&appVersion=%@", [self baseUrlStringWithNoAppId], appVersion];
}

/// 发送频道消息
+ (NSString *)urlSendMsgWithRoomId:(NSString *)roomId userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@rooms/%@/users/%@/chat/channel", [self baseUrlString], roomId, userId];
}

+ (void)setAppId:(NSString *)appId {
    _appId = appId;
}

@end
