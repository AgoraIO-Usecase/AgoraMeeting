//
//  HMRoom.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/21.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 分享类型
typedef NS_ENUM(NSUInteger, HMShareType) {
    /// 关闭
    HMShareTypeClose = 0,
    /// 屏幕分享
    HMShareTypeScreen = 1,
    /// 白板分享
    HMShareTypeWhiteBoard = 2,
};

@class HMRoomInfo, HMRoomProperties, HMUserPermission, HMUserInfo, HMStreamInfo;

NS_ASSUME_NONNULL_BEGIN



@interface HMRoomInfo : NSObject

@property (nonatomic, copy)NSString *roomId;
@property (nonatomic, copy)NSString *roomName;
@property (nonatomic, copy)NSString *roomPassword;

@end

@interface HMRoomProperties : NSObject

@property(nonatomic, strong)HMUserPermission *userPermission;
@property(nonatomic, strong)HMRoomInfo *roomInfo;
/// 原因
@property(nonatomic, copy)NSString *cause;

@end

@interface HMUserPermission : NSObject

@property (nonatomic, assign)BOOL micAccess;
@property (nonatomic, assign)BOOL cameraAccess;

@end

@interface HMShare : NSObject

@property (nonatomic, assign)HMShareType type;
@property (nonatomic, assign)BOOL cameraAccess;

@end

@interface HMScreen : NSObject

/// 屏幕分享的用户信息
@property (nonatomic, strong)HMUserInfo *ownerInfo;
/// 屏幕分享的流信息
@property (nonatomic, strong)HMStreamInfo *streamInfo;

@end

@interface HMWhiteBoard : NSObject

@property (nonatomic, copy)NSString *boardId;
@property (nonatomic, copy)NSString *boardToken;
@property (nonatomic, strong)HMUserInfo *ownerInfo;
/// 操作者用户列表 包含白板分享的用户信息
@property (nonatomic, copy)NSArray<HMUserInfo *> *operatorList;

@end



NS_ASSUME_NONNULL_END
