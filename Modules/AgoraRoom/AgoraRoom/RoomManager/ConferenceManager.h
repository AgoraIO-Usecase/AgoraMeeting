//
//  ConferenceManager.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConferenceDelegate.h"
#import "ConfRoomAllModel.h"
#import "RoomEnum.h"
#import "ConferenceEntryParams.h"
#import "ConfUserListInfoModel.h"
#import "WhiteInfoModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConferenceManager : NSObject
@property (nonatomic, weak) id<ConferenceDelegate> delegate;

@property (nonatomic, strong) ConfRoomModel * _Nullable roomModel;
@property (nonatomic, strong) ConfUserModel * _Nullable ownModel;
@property (nonatomic, strong) NSArray<ConfUserModel *> *userListModels;

- (instancetype)initWithSceneType:(SceneType)type appId:(NSString *)appId authorization:(NSString *)authorization;
- (void)netWorkProbeTestCompleteBlock:(void (^ _Nullable) (NetworkGrade grade))block;
    
// init media
- (void)initMediaWithClientRole:(ClientRole)role successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock;

// entry room
- (void)entryConfRoomWithParams:(ConferenceEntryParams *)params successBolck:(void (^ )(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock;

// get room info
- (void)getConfRoomInfoWithSuccessBlock:(void (^)(ConfRoomInfoModel *roomInfoModel))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock;

//  update room info
- (void)updateRoomInfoWithValue:(NSInteger)value enableSignalType:(ConfEnableRoomSignalType)type successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock;

// get user list info
- (void)getUserListWithSuccessBlock:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock;

//  update users info
- (void)updateUserInfoWithUserId:(NSString*)userId value:(BOOL)enable enableSignalType:(EnableSignalType)type successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock;

- (void)changeHostWithUserId:(NSString *)userId completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

//  update white state
- (void)whiteBoardStateWithValue:(BOOL)enable userId:(NSString *)userId  completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

// send message
- (void)sendMessageWithText:(NSString *)message successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

- (void)p2pActionWithType:(EnableSignalType)type actionType:(P2PMessageTypeAction)actionType userId:(NSString *)userId completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

// upload log
- (void)uploadLogWithSuccessBlock:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock;

// left room
- (void)leftRoomWithUserId:(NSString *)userId successBolck:(void (^ _Nullable)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock;

// get white info
- (void)getWhiteInfoWithSuccessBlock:(void (^ _Nullable) (WhiteInfoModel * model))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock;

- (NSInteger)submitRating:(NSInteger)rating;

- (NSInteger)switchCamera;

// Canvas

- (void)addVideoCanvasWithUId:(NSUInteger)uid inView:(UIView *)view showType:(ShowViewType)showType;
- (void)addVideoCanvasWithUId:(NSUInteger)uid inView:(UIView *)view;
- (void)removeVideoCanvasWithUId:(NSUInteger)uid;
- (void)removeVideoCanvasWithView:(UIView *)view;

- (void)releaseResource;
@end

NS_ASSUME_NONNULL_END
