//
//  EduRoomModel.m
//  AgoraRoom
//
//  Created by SRS on 2020/5/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduRoomModel.h"

@implementation EduRoomModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"coVideoUsers" : [EduUserModel class]};
}
@end
