//
//  EduRoomModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduRoomModel : NSObject
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *channelName;

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger courseState;// 1=inclass 2=outclass

@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger muteAllChat;

@property (nonatomic, assign) NSInteger isRecording;
@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, assign) NSInteger recordingTime;
@property (nonatomic, assign) NSInteger lockBoard; //1=locked 0=no lock
@property (nonatomic, strong) NSArray<EduUserModel*> *coVideoUsers;
@end

NS_ASSUME_NONNULL_END
