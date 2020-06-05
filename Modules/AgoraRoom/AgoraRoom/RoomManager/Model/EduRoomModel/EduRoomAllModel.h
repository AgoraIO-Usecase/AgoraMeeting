//
//  EduRoomAllModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduUserModel.h"
#import "EduRoomModel.h"
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduRoomInfoModel : NSObject
@property (nonatomic, strong) EduRoomModel *room;
@property (nonatomic, strong) EduUserModel *localUser;
@end

@interface EduRoomAllModel : BaseModel
@property (nonatomic, strong) EduRoomInfoModel *data;
@end

NS_ASSUME_NONNULL_END
