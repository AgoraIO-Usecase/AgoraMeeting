//
//  SignalRoomModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/22.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface SignalRoomInfoModel : NSObject
@property (nonatomic, assign) NSInteger muteAllChat;
@property (nonatomic, assign) NSInteger lockBoard;
@property (nonatomic, assign) NSInteger courseState;
@property (nonatomic, assign) NSInteger startTime;
@end

@interface SignalRoomModel : NSObject
@property (nonatomic, assign) NSInteger cmd;
@property (nonatomic, strong) SignalRoomInfoModel *data;
@end

NS_ASSUME_NONNULL_END
