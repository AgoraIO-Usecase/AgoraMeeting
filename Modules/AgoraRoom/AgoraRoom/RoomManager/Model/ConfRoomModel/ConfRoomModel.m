//
//  EduRoomModel.m
//  AgoraRoom
//
//  Created by SRS on 2020/5/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ConfRoomModel.h"

@implementation ConfRoomModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"hosts" : [ConfUserModel class],
        @"shareScreenUsers" : [ConfShareScreenUserModel class],
        @"shareBoardUsers" : [ConfShareBoardUserModel class],
    };
}

@end
