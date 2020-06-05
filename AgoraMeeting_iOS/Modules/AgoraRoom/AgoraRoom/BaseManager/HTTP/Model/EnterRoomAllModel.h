//
//  EnterRoomAllModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/7.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EnterRoomModel :NSObject
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, assign) NSInteger type;

@end

@interface EnterUserModel :NSObject
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString *rtmToken;

@end


@interface EnterRoomInfoModel :NSObject

// demo & conference
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userToken;

// welare
@property (nonatomic, strong) EnterRoomModel *room;
@property (nonatomic, strong) EnterUserModel *user;

@end


@interface EnterRoomAllModel :BaseModel
@property (nonatomic, strong) EnterRoomInfoModel *data;

@end

NS_ASSUME_NONNULL_END
