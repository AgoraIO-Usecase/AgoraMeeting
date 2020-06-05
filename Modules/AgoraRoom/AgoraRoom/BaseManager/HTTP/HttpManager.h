//
//  HttpManager.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigModel.h"
#import "EnterRoomAllModel.h"
#import "SignalEnum.h"
#import "EduRoomAllModel.h"
#import "ConfRoomAllModel.h"
#import "LogParamsModel.h"
#import "WhiteModel.h"
#import "ReplayModel.h"

#import "EduSaaSEntryParams.h"
#import "EduEntryParams.h"
#import "ConferenceEntryParams.h"
#import "RoomEnum.h"
#import "ConfUserListModel.h"

typedef NS_ENUM(NSUInteger, MessageType) {
    MessageTypeText = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface HttpManager : NSObject

+ (void)saveHttpHeader2:(NSString *)auth;
+ (void)saveSceneType:(SceneType)type;

// service
+ (void)getConfigWithApiVersion:(NSString *)apiVersion successBolck:(void (^ _Nullable) (ConfigAllInfoModel * model))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (void)enterRoomWithParams:(EntryParams *)params appId:(NSString *)appId  apiVersion:(NSString *)apiVersion successBolck:(void (^ _Nullable) (EnterRoomInfoModel *model))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (void)sendMessageWithType:(MessageType)messageType appId:(NSString *)appId roomId:(NSString *)roomId message:(NSString *)message apiVersion:(NSString *)apiVersion successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (void)sendCoVideoWithType:(SignalLinkState)linkState appId:(NSString *)appId roomId:(NSString *)roomId userIds:(NSArray<NSString *> *)userIds apiVersion:(NSString *)apiVersion successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (void)updateRoomInfoWithValue:(NSInteger)value enableSignalType:(ConfEnableRoomSignalType)type appId:(NSString *)appId roomId:(NSString *)roomId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (void)getUserListWithRole:(ConfRoleType)role nextId:(NSString *)nextId count:(NSInteger)count appId:(NSString *)appId roomId:(NSString *)roomId apiVersion:(NSString *)apiVersion successBlock:(void (^)(ConfUserListInfoModel *userListModel))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (void)updateUserInfoWithValue:(BOOL)enable enableSignalType:(EnableSignalType)type appId:(NSString *)appId roomId:(NSString *)roomId userId:(NSString *)byUserId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (void)changeHostWithAppId:(NSString *)appId roomId:(NSString *)roomId userId:(NSString *)userId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (void)whiteBoardStateWithValue:(NSInteger)value appId:(NSString *)appId roomId:(NSString *)roomId userId:(NSString *)targetUserId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

//+ (void)sendCoVideoWithType:(SignalLinkState)linkState appId:(NSString *)appId roomId:(NSString *)roomId userIds:(NSArray<NSString *> *)userIds apiVersion:(NSString *)apiVersion successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

// value：1=邀请 2=拒绝
+ (void)hostActionWithType:(EnableSignalType)type value:(NSInteger)value appId:(NSString *)appId roomId:(NSString *)roomId userId:(NSString *)userId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;
// value：1=申请 2=拒绝
+ (void)audienceActionWithType:(EnableSignalType)type value:(NSInteger)value appId:(NSString *)appId roomId:(NSString *)roomId userId:(NSString *)userId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (void)getRoomInfoWithAppId:(NSString *)appId roomId:(NSString *)roomId  apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (id responseModel))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (void)leftRoomWithAppId:(NSString *)appId roomId:(NSString *)roomId userId:(NSString *)userId apiVersion:(NSString *)apiVersion successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

// log
+ (void)getLogInfoWithAppId:(NSString *)appId roomId:(NSString *)roomId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (LogParamsInfoModel * model))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

// white info
+ (void)getWhiteInfoWithAppId:(NSString *)appId roomId:(NSString *)roomId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (WhiteInfoModel *model))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

// repaly
+ (void)getReplayInfoWithAppId:(NSString *)appId roomId:(NSString *)roomId  recordId:(NSString *)recordId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^)(ReplayInfoModel *model))successBlock completeFailBlock:(void (^)(NSError *error))failBlock;

@end

NS_ASSUME_NONNULL_END
