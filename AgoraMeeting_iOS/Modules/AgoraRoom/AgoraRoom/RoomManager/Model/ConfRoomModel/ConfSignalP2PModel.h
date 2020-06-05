//
//  ConfSignalP2PModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseSignalModel.h"

typedef NS_ENUM(NSInteger, P2PMessageType) {
    P2PMessageTypeInvitation            = 1,
    P2PMessageTypeApply                 = 2,
    P2PMessageTypeTip                   = 3,
};

typedef NS_ENUM(NSInteger, P2PMessageTypeAction) {
    P2PMessageTypeActionInvitation            = 10,
    P2PMessageTypeActionRejectApply           = 11,
    
    P2PMessageTypeActionApply                 = 20,
    P2PMessageTypeActionRejectInvitation      = 21,
    
    P2PMessageTypeActionOpenTip               = 30,
    P2PMessageTypeActionCloseTip              = 31,
};

typedef NS_ENUM(NSInteger, P2PMessageTypeActionType) {
    P2PMessageTypeActionTypeAudio               = 1,
    P2PMessageTypeActionTypeVideo               = 2,
    P2PMessageTypeActionTypeBoard               = 3,
    P2PMessageTypeActionTypeIM                  = 4,
};

NS_ASSUME_NONNULL_BEGIN

@interface ConfSignalP2PInfoModel : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) P2PMessageTypeActionType type;
@property (nonatomic, assign) P2PMessageTypeAction action;

@end

@interface ConfSignalP2PModel : NSObject

@property (nonatomic, assign) P2PMessageType cmd;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger timestamp;
@property (nonatomic, strong) ConfSignalP2PInfoModel *data;

@end

NS_ASSUME_NONNULL_END
