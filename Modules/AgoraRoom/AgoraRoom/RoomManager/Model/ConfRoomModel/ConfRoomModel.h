//
//  EduRoomModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfUserModel.h"
#import "ConfShareScreenUserModel.h"
#import "ConfShareBoardUserModel.h"

typedef NS_ENUM(NSUInteger, MuteAllAudioState) {
    MuteAllAudioStateUnmute = 0,
    MuteAllAudioStateAllowUnmute = 1,
    MuteAllAudioStateNoAllowUnmute = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface ConfRoomModel : NSObject
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) NSInteger muteAllChat;
@property (nonatomic, assign) MuteAllAudioState muteAllAudio;
@property (nonatomic, assign) NSInteger shareBoard;
@property (nonatomic, assign) NSInteger shareScreen;
@property (nonatomic, assign) NSInteger onlineUsers;
@property (nonatomic, strong) NSString *createBoardUserId;
@property (nonatomic, assign) NSInteger startTime;

@property (nonatomic, strong) NSArray<ConfUserModel*> *hosts;
@property (nonatomic, strong) NSArray<ConfShareScreenUserModel*> *shareScreenUsers;
@property (nonatomic, strong) NSArray<ConfShareBoardUserModel*> *shareBoardUsers;

@end

NS_ASSUME_NONNULL_END
