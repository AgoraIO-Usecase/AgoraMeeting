//
//  HttpManager+Public.m
//  AgoraRoom
//
//  Created by ZYP on 2021/1/11.
//  Copyright © 2021 agora. All rights reserved.
//

#import "HttpManager+Public.h"
#import "HMUserInfo.h"
#import "HMRequestParams.h"
#import "HMResponeParams.h"
#import "HttpManager+Url.h"
#import <YYModel/YYModel.h>
#import "HMRespone.h"
#import "HMError.h"

@implementation HttpManager (Public)

/// 5.2.1 创建/加入房间
+ (void)requestAddRoom:(HMReqParamsAddRoom * _Nonnull)request
               success:(HMSuccessBlockAddRoom _Nullable)success
               failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlAddRoomWitthRoomId:request.roomId];
    NSDictionary *params = [request yy_modelToJSONObject];
    [HttpManager post:url params:params headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        HMResponeParamsAddRoom *respParams = [HMResponeParamsAddRoom yy_modelWithDictionary:resp.data];
        if(success) { success(respParams); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.2.2 离开房间
+ (void)requestLeaveRoomWithRoomId:(NSString *)roomId
                            userId:(NSString *)userId
                           success:(HMSuccessBlockVoid _Nullable)success
                           faulure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlLeaveRoomWitthRoomId:roomId userId:userId];
    NSDictionary *params = @{@"roomId": roomId,
                             @"userId": userId};
    [HttpManager post:url params:params headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError * error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.1 用户权限更新
+ (void)requestUserPermissionsUpdate:(HMReqParamsUserPermissionsAll * _Nonnull)request
                             success:(HMSuccessBlockVoid _Nullable)success
                             failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlUserPermissionsWitthRoomId:request.roomId userId:request.userId];
    NSDictionary *params = [request yy_modelToJSONObject];
    [HttpManager put:url params:params headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.2 全员关闭摄像头/麦克风
+ (void)requestAVCloseAll:(HMRequestParamsUserPermissionsCloseAll * _Nonnull)request
                               success:(HMSuccessBlockVoid _Nullable)success
                               failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlPermissionCLoseAllWitthRoomId:request.roomId userId:request.userId];
    NSDictionary *params = [request yy_modelToJSONObject];
    [HttpManager post:url params:params headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.3 关闭单人摄像头/麦克风
+ (void)reqCloseCameraMicSingle:(HMReqParamsUserPermissionsCloseSingle * _Nonnull)request
                            success:(HMSuccessBlockVoid _Nullable)success
                            failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlPermissionCLoseSingleWitthRoomId:request.roomId userId:request.userId];
    NSDictionary *params = [request yy_modelToJSONObject];
    [params setValue:nil forKey:@"roomId"];
    [params setValue:nil forKey:@"userId"];
    [HttpManager post:url params:params headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.4 踢人
+ (void)requestKickout:(HMReqParamsKickout * _Nonnull)request
               success:(HMSuccessBlockVoid _Nullable)success
               failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlKickoutWitthRoomId:request.roomId userId:request.userId];
    NSDictionary *params = [request yy_modelToJSONObject];
    [HttpManager post:url params:params headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.5 转交主持人
+ (void)requestHostTransferWithParam:(HMReqParamsHostTransfer * _Nonnull)param
                             success:(HMSuccessBlockBool _Nullable)success
                             failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlTransferHostWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        HMResponeParamsBool *respParams = [HMResponeParamsBool yy_modelWithDictionary:resp.data];
        if(success) { success(respParams.ok); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.7 放弃主持人
+ (void)requestHostAbandonWithParam:(HMReqParamsHostAbondon * _Nonnull)param
                            success:(HMSuccessBlockVoid _Nullable)success
                            failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlAbandonHostWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.8 开始录制
+ (void)requestRecordStartWithParam:(HMReqParamsRecordStart * _Nonnull)param
                            success:(HMSuccessBlockBool _Nullable)success
                            failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlRecordStartWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        HMResponeParamsBool *respParams = [HMResponeParamsBool yy_modelWithDictionary:resp.data];
        if(success) { success(respParams.ok); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.9 关闭录制
+ (void)requestRecordStopWithParam:(HMReqParamsRecordStop * _Nonnull)param
                           success:(HMSuccessBlockBool _Nullable)success
                           failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlRecordStopWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        HMResponeParamsBool *respParams = [HMResponeParamsBool yy_modelWithDictionary:resp.data];
        if(success) { success(respParams.ok); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.10 接受打开摄像头/麦克风的请求
+ (void)requestUserPermissionsRequestAcceptWitthParam:(HMReqParamsUserPermissionsRequestAccept * _Nonnull)param
                                              success:(HMSuccessBlockVoid _Nullable)success
                                              failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlPermissionAceptWitthRoomId:param.roomId userId:param.userId requestId:param.requestId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.11 拒绝打开摄像头/麦克风的请求
+ (void)requestUserPermissionsRequestRejectWitthParam:(HMRequestParamsUserPermissionsRequestReject * _Nonnull)param
                                              success:(HMSuccessBlockBool _Nullable)success
                                              failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlPermissionRejectWitthRoomId:param.roomId userId:param.userId requestId:param.requestId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        HMResponeParamsBool *respParams = [HMResponeParamsBool yy_modelWithDictionary:resp.data];
        if(success) { success(respParams.ok); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.12. 结束会议
+ (void)requestEndRoomWithRoomId:(NSString *)roomId
                          userId:(NSString *)userId
                         success:(HMSuccessBlockVoid _Nullable)success
                         faulure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlEndRoomWitthRoomId:roomId userId:userId];
    NSDictionary *params = @{@"roomId": roomId,
                             @"userId": userId};
    [HttpManager post:url params:params headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError * error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.1.6. 指定主持人
+ (void)requestAppointHostWithParam:(HMReqParamsAppointHost *_Nonnull)param
                            success:(HMSuccessBlockVoid _Nullable)success
                            failure:(HMFailBlock _Nullable)failure {
      NSString *url = [HttpManager urlAppointHostWitthRoomId:param.roomId userId:param.userId];
      NSDictionary *paramDict = [param yy_modelToJSONObject];
      [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
          HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
          if(![self checkResp:resp failure:failure]) { return; }
          if(success) { success(); }
      } failure:^(NSError *error) {
          if(error) { failure(error); }
      }];
  }

/// 申请成为主持人 (应该叫设为主持人)
+ (void)requestHostApplyWithParam:(HMReqParamsHostApply * _Nonnull)param
                          success:(HMSuccessBlockVoid _Nullable)success
                          failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlHostApplyWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 请求打开摄像头/麦克风
+ (void)requestPermissionApplyWithParam:(HMRequestParamsPermissionsApply * _Nonnull)param
                                success:(HMSuccessBlockAVAccess _Nullable)success
                                failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlPermissionApplyWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        HMResponeParamsAVAccess *respParams = [HMResponeParamsAVAccess yy_modelWithDictionary:resp.data];
        if(success) { success(respParams); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 更新会议内的房间信息
+ (void)requestRoomInfoUpdateWithParam:(HMReqParamsRoomInfoUpdate * _Nonnull)param
                               success:(HMSuccessBlockVoid _Nullable)success
                               failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlRoomInfoUpdateWithRoomId:param.roomId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager put:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 更新房间内用户信息
+ (void)requestUserInfoWithParam:(HMReqParamsUserInfoUpdate * _Nonnull)param
                         success:(HMSuccessBlockVoid _Nullable)success
                         failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlUserInfoUpdateWithRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager put:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 发起屏幕共享
+ (void)requestScreenShareStartWithParam:(HMReqParamsScreenShareSatrt * _Nonnull)param
                                 success:(HMSuccessBlockScreenStart _Nullable)success
                                 failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlShareScreenStartWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        HMResponeParamsScreenStart *obj = [HMResponeParamsScreenStart yy_modelWithDictionary:resp.data];
        if(success) { success(obj); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 关闭屏幕共享
+ (void)requestScreenShareStopWithParam:(HMReqScreenShareStop * _Nonnull)param
                                success:(HMSuccessBlockVoid _Nullable)success
                                failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlShareScreenStopWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 发起白板
+ (void)requestWhiteBoardStartWithParam:(HMReqParamsParamsWihleBoardStart * _Nonnull)param
                                success:(HMSuccessBlockVoid _Nullable)success
                                failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlWhiteBoardStartWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.3.6. 关闭白板
+ (void)requestWhiteBoardStopWithParam:(HMReqParamsWihleBoardStop * _Nonnull)param
                               success:(HMSuccessBlockVoid _Nullable)success
                               failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlWhiteBoardStopWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.3.7. 申请白板互动
+ (void)requestWhiteBoardInteractWithParam:(HMReqParamsWihleBoardInteract * _Nonnull)param
                                   success:(HMSuccessBlockVoid _Nullable)success
                                   failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlWhiteBoardInteractWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.3.3.8. 离开白板互动
+ (void)requestWhiteBoardLeaveWithParam:(HMReqParamsWihleBoardLeave * _Nonnull)param
                                success:(HMSuccessBlockVoid _Nullable)success
                                failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlWhiteBoardLeaveWitthRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

/// 5.4.2. 获取 App 版本配置
+ (void)requestAppVersionWithAppVersion:(NSString * _Nonnull)appVersion
                                success:(HMSuccessBlockAppVersion _Nullable)success
                                failure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlAppVersionWithAppVersion:appVersion];
    [HttpManager get:url params:@{} headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        HMResponeParamsAppVersion *obj = [HMResponeParamsAppVersion yy_modelWithDictionary:resp.data];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(obj); }
    } failure:^(NSError * error) {
        if(error) { failure(error); }
    }];
}


/// 5.3.3.10. 发送频道消息
+ (void)requestSendMsg:(HMReqChannelMsg * _Nonnull)param
               success:(HMSuccessBlockVoid _Nullable)success
               faulure:(HMFailBlock _Nullable)failure {
    NSString *url = [HttpManager urlSendMsgWithRoomId:param.roomId userId:param.userId];
    NSDictionary *paramDict = [param yy_modelToJSONObject];
    [HttpManager post:url params:paramDict headers:nil success:^(id responeObj) {
        HMRespone *resp = [HMRespone yy_modelWithDictionary:responeObj];
        if(![self checkResp:resp failure:failure]) { return; }
        if(success) { success(); }
    } failure:^(NSError *error) {
        if(error) { failure(error); }
    }];
}

@end
