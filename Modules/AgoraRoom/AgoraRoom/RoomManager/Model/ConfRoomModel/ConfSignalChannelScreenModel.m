//
//  ConfSignalChannelScreenModel.m
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ConfSignalChannelScreenModel.h"

@implementation ConfSignalChannelScreenModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"shareScreenUsers" : [ConfShareScreenUserModel class]};
}

@end
