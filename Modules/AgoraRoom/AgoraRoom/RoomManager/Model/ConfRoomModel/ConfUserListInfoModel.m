//
//  ConfUserListInfoModel.m
//  AgoraRoom
//
//  Created by SRS on 2020/5/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ConfUserListInfoModel.h"

@implementation ConfUserListInfoModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"list" : [ConfUserModel class],
    };
}
@end
