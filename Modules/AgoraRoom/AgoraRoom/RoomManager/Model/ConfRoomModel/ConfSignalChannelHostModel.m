//
//  ConfSignalChannelHostModel.m
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ConfSignalChannelHostModel.h"

@implementation ConfSignalChannelHostModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : [ConfUserModel class]};
}
@end
