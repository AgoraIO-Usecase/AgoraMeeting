//
//  SignalUserModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/22.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalEnum.h"
#import "EduRoomAllModel.h"
#import "EduUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SignalUserModel : NSObject
// MessageCmdTypeUserInfo
@property (nonatomic, assign) MessageCmdType cmd;
@property (nonatomic, strong) NSArray<EduUserModel*> *data;
@end

NS_ASSUME_NONNULL_END
