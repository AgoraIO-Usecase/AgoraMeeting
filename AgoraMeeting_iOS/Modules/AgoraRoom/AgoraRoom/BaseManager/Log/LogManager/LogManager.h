//
//  LogManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/3/24.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "RoomEnum.h"

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

#define AgoraLogError(frmt, ...)   LOG_MAYBE(NO,                LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define AgoraLogWarn(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define AgoraLogInfo(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define AgoraLogDebug(frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define AgoraLogVerbose(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

@interface LogManager : NSObject

+ (void)uploadLogWithSceneType:(SceneType)sceneType appId:(NSString *)appId roomId:(NSString *)roomId apiVersion:(NSString*)apiVersion completeSuccessBlock:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

@end

NS_ASSUME_NONNULL_END
