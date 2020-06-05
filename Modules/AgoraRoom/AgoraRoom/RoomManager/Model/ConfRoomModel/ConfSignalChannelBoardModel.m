//
//  ConfSignalChannelBoardModel.m
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ConfSignalChannelBoardModel.h"

@implementation ConfSignalChannelBoardModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"shareBoardUsers" : [ConfShareBoardUserModel class]};
}

@end
