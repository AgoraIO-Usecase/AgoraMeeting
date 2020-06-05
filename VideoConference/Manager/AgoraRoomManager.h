//
//  AgoraRoomManager.h
//  VideoConference
//
//  Created by SRS on 2020/5/7.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRoom/AgoraRoom.h>
#import <WhiteModule/WhiteModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRoomManager : NSObject

@property (nonatomic, strong) ConferenceManager *conferenceManager;
@property (nonatomic, strong) WhiteManager *whiteManager;

@property (nonatomic, strong) NSMutableArray<MessageInfoModel*> *messageInfoModels;

+ (instancetype)shareManager;
+ (void)releaseResource;

@end

NS_ASSUME_NONNULL_END
