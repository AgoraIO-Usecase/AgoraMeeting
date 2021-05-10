//
//  HMUser.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/21.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMUserInfo : NSObject

@property (nonatomic, copy)NSString *userId;
@property (nonatomic, copy)NSString *userName;

/**
 用户角色

 'host': 主持人

 'broadcast': 发流观众

 'audience': 观众
 */
@property (nonatomic, copy)NSString *userRole;

@end

NS_ASSUME_NONNULL_END
