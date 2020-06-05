//
//  ConfSignalChannelKickoutModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfSignalChannelKickoutModel : NSObject

@property (nonatomic, strong) NSString *hostUserId;
@property (nonatomic, strong) NSString *hostUserName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;

@end

NS_ASSUME_NONNULL_END
