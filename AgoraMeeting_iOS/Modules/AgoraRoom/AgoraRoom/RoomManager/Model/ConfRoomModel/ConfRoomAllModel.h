//
//  EduRoomAllModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfUserModel.h"
#import "ConfRoomModel.h"
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfRoomInfoModel : NSObject
@property (nonatomic, strong) ConfRoomModel *room;
@property (nonatomic, strong) ConfUserModel *localUser;
@end

@interface ConfRoomAllModel : BaseModel
@property (nonatomic, strong) ConfRoomInfoModel *data;
@end

NS_ASSUME_NONNULL_END
