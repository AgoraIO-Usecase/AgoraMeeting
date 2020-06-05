//
//  BaseConfigModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiLanguageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseConfigModel : NSObject

@property (nonatomic, strong) MultiLanguageModel *multiLanguage;

@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* userToken;

@property (nonatomic, strong) NSString* roomId;
@property (nonatomic, strong) NSString* appId;
@property (nonatomic, assign) NSInteger uid;//rtm&rtc
@property (nonatomic, strong) NSString* channelName;

@property (nonatomic, strong) NSString* rtcToken;
@property (nonatomic, strong) NSString* rtmToken;
@property (nonatomic, strong) NSString* boardId;
@property (nonatomic, strong) NSString* boardToken;

@end

NS_ASSUME_NONNULL_END
