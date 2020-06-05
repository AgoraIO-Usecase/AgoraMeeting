//
//  ConfSignalChannelInOutModel.m
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ConfSignalChannelInOutModel.h"

@implementation ConfSignalChannelInOutInfoModel

@end

@implementation ConfSignalChannelInOutModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [ConfSignalChannelInOutInfoModel class]};
}
@end
