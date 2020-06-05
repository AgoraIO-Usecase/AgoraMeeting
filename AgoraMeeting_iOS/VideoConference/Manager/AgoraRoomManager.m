//
//  AgoraRoomManager.m
//  VideoConference
//
//  Created by SRS on 2020/5/7.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRoomManager.h"
#import "KeyCenter.h"

static AgoraRoomManager *manager = nil;

@implementation AgoraRoomManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AgoraRoomManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if(self = [super init]) {
        NSString *appid = [KeyCenter agoraAppid];
        NSString *authorization = [KeyCenter authorization];
        self.conferenceManager =  [[ConferenceManager alloc]initWithSceneType:SceneTypeConference appId:appid authorization:authorization];
        self.whiteManager = [WhiteManager new];
        
        self.messageInfoModels = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWillTerminate) name:NOTICENAME_ON_WILL_TERMINATE object:nil];
    }
    return self;
}

- (void)onWillTerminate {
    [AgoraRoomManager releaseResource];
}

+ (void)releaseResource {
    [AgoraRoomManager.shareManager.conferenceManager releaseResource];
    [AgoraRoomManager.shareManager.whiteManager releaseWhiteResources];
    AgoraRoomManager.shareManager.messageInfoModels = [NSMutableArray array];
}

@end
