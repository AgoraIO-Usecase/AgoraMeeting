//
//  RoomManager.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import "RoomManager.h"
#import "RTCManager.h"
#import "RTMManager.h"
#import "HttpManager.h"
#import "LogManager.h"
#import "URL.h"
#import "EduConfigModel.h"
#import "JsonParseUtil.h"
#import "VideoSessionModel.h"

@interface RoomManager()<RTMManagerDelegate, RTCManagerDelegate>

@property (nonatomic, strong) RTCManager *rtcManager;
@property (nonatomic, strong) RTMManager *rtmManager;
@property (nonatomic, strong) NSMutableArray<VideoSessionModel*> *rtcVideoSessionModels;

@property (nonatomic, assign) SceneType sceneType;

@end

@implementation RoomManager

- (instancetype)init {
    NSAssert(1 == 0, @"inti must use: initWithSceneType");
    return self;
}

- (instancetype)initWithSceneType:(SceneType)type appId:(NSString *)appId authorization:(NSString *)authorization configModel:(BaseConfigModel *)configModel {
    if (self = [super init]) {
        self.rtcVideoSessionModels = [NSMutableArray array];
        self.sceneType = type;
        self.baseConfigModel = configModel;
        [HttpManager saveHttpHeader2:authorization];
        [HttpManager saveSceneType:type];
    }
    return self;
}

- (void)startNetWorkProbeTest:(NSString *)appid {
    self.rtcManager = [RTCManager new];
    [self.rtcManager startLastmileProbeTest:appid dataSourceDelegate:self];
}

#pragma mark entry room start
- (void)entryEduSaaSRoomWithParams:(EduSaaSEntryParams *)params successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
//    self.baseConfigModel.userName = params.userName;
//    self.baseConfigModel.password = params.password;
//
//    [self enterRoomProcess:params successBolck:successBlock failBlock:failBlock];
}

- (void)enterRoomProcess:(EntryParams *)params configApiVersion:(NSString*)configApiVersion entryApiVersion:(NSString*)entryApiVersion roomInfoApiVersion:(NSString*)roomInfoApiVersion successBolck:(void (^)(id roomInfoModel))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    [self getConfigWithApiVersion:configApiVersion successBolck:^{
        [weakself getEntryInfoWithParams:params apiVersion:entryApiVersion successBolck:^{
            [weakself getRoomInfoWithApiversion:roomInfoApiVersion successBlock:^(id  _Nonnull roomInfoModel) {
                
                if([roomInfoModel isKindOfClass:[ConfRoomInfoModel class]]) {
                    ConfRoomInfoModel *model = (ConfRoomInfoModel*)roomInfoModel;
                    weakself.baseConfigModel.rtmToken = model.localUser.rtmToken;
                    weakself.baseConfigModel.uid = model.localUser.uid;
                    weakself.baseConfigModel.channelName = model.room.channelName;
                }
                
                [weakself setupRTMWithSuccessBolck:^{
                    if(successBlock != nil){
                       successBlock(roomInfoModel);
                    }
                } failBlock:^(NSInteger errorCode) {
                    if(failBlock != nil){
                        NSString *errorStr = Localized(@"RTMInitErrorText");
                        errorStr = [NSString stringWithFormat:@"%@:%ld", errorStr, (long)errorCode];
                        NSError *error = LocalError(LocalAgoraErrorCodeCommon, errorStr);
                        failBlock(error);
                    }
                }];
            } failBlock:failBlock];
        } failBlock:failBlock];
    } failBlock:failBlock];
}
#pragma mark entry room end

- (void)initMediaWithClientRole:(ClientRole)role successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    [self setupRTCWithClientRole:role successBolck:successBlock failBlock:failBlock];
}

- (void)sendMessageWithText:(NSString *)message apiversion:(NSString *)apiversion successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    
    WEAK(self);
    [HttpManager sendMessageWithType:MessageTypeText appId:appId roomId:roomId message:message apiVersion:apiversion successBolck:^{
        
        if(successBlock != nil){
           successBlock();
        }
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil){
           failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)addVideoCanvasWithUId:(NSUInteger)uid inView:(UIView *)view showType:(ShowViewType)showType {
    
    VideoSessionModel *currentSessionModel;
    VideoSessionModel *removeSessionModel;
    for (VideoSessionModel *videoSessionModel in self.rtcVideoSessionModels) {
        // view rerender
        if(videoSessionModel.videoCanvas.view == view){
            if(videoSessionModel.videoCanvas.uid == uid) {
                continue;
            }
            
            videoSessionModel.videoCanvas.view = nil;
            if(videoSessionModel.uid == self.baseConfigModel.uid) {
                [self.rtcManager setupLocalVideo:videoSessionModel.videoCanvas];
            } else {
                [self.rtcManager setupRemoteVideo:videoSessionModel.videoCanvas];
            }
            removeSessionModel = videoSessionModel;

        } else if(videoSessionModel.uid == uid){
            videoSessionModel.videoCanvas.view = nil;
            if(videoSessionModel.uid == self.baseConfigModel.uid) {
                [self.rtcManager setupLocalVideo:videoSessionModel.videoCanvas];
            } else {
                [self.rtcManager setupRemoteVideo:videoSessionModel.videoCanvas];
            }
            currentSessionModel = videoSessionModel;
        }
    }
    if(removeSessionModel != nil){
        [self.rtcVideoSessionModels removeObject:removeSessionModel];
    }
    if(currentSessionModel != nil){
        [self.rtcVideoSessionModels removeObject:currentSessionModel];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
            videoCanvas.uid = uid;
            videoCanvas.view = view;
            if(showType == ShowViewTypeFit){
                videoCanvas.renderMode = AgoraVideoRenderModeFit;
            } else if(showType == ShowViewTypeHidden){
                videoCanvas.renderMode = AgoraVideoRenderModeHidden;
            }
            if(uid == self.baseConfigModel.uid) {
                [self.rtcManager setupLocalVideo: videoCanvas];
            } else {
                [self.rtcManager setupRemoteVideo: videoCanvas];
            }
            
            VideoSessionModel *videoSessionModel = [VideoSessionModel new];
            videoSessionModel.uid = uid;
            videoSessionModel.videoCanvas = videoCanvas;
            [self.rtcVideoSessionModels addObject:videoSessionModel];
            
            // low stream
        //    if(self.baseConfigModel.sceneType == 1) {
        //        if(uid != self.baseConfigModel.uid) {
        //            [self.rtcManager setRemoteVideoStream:uid type:AgoraVideoStreamTypeLow];
        //        }
        //    }
            
            // role
            if(uid == self.baseConfigModel.uid) {
                [self.rtcManager setClientRole:AgoraClientRoleBroadcaster];
            }
    });
}

- (void)removeVideoCanvasWithUId:(NSUInteger)uid {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", uid];
    NSArray<VideoSessionModel *> *filteredArray = [self.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
    if(filteredArray > 0) {
        VideoSessionModel *model = filteredArray.firstObject;
        model.videoCanvas.view = nil;
        if(uid == self.baseConfigModel.uid) {
            [self.rtcManager setupLocalVideo:model.videoCanvas];
//            [self.rtcManager setClientRole:AgoraClientRoleAudience];
        } else {
            [self.rtcManager setupRemoteVideo:model.videoCanvas];
        }
        [self.rtcVideoSessionModels removeObject:model];
    }
}
- (void)removeVideoCanvasWithView:(UIView *)view {
    for (VideoSessionModel *model in self.rtcVideoSessionModels) {
        if(model.videoCanvas.view == view) {
            model.videoCanvas.view = nil;
            if(model.uid == self.baseConfigModel.uid) {
                [self.rtcManager setupLocalVideo:model.videoCanvas];
//                [self.rtcManager setClientRole:AgoraClientRoleAudience];
            } else {
                [self.rtcManager setupRemoteVideo:model.videoCanvas];
            }
            [self.rtcVideoSessionModels removeObject:model];
            break;
        }
    }
}

- (void)getUserListWithNextId:(NSString *)nextId count:(NSInteger)count apiversion:(NSString *)apiversion successBlock:(void (^)(ConfUserListInfoModel *userListModel))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    [HttpManager getUserListWithRole:ConfRoleTypeParticipant nextId:nextId count:count appId:appId roomId:roomId apiVersion:apiversion successBlock:successBlock failBlock:^(NSError * _Nonnull error) {
        
        if(failBlock != nil){
           failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)updateUserInfoWithUserId:(NSString*)userId  value:(BOOL)enable enableSignalType:(EnableSignalType)type apiversion:(NSString *)apiversion successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    [HttpManager updateUserInfoWithValue:enable enableSignalType:type appId:appId roomId:roomId userId:userId apiVersion:apiversion completeSuccessBlock:^{
        if(successBlock != nil){
           successBlock();
        }
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil){
           failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)changeHostWithUserId:(NSString *)targetUserId completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    
    WEAK(self);
    [HttpManager changeHostWithAppId:appId roomId:roomId userId:targetUserId apiVersion:APIVersion1 completeSuccessBlock:successBlock completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil){
           failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

//  update white state
- (void)whiteBoardStateWithValue:(NSInteger)value userId:(NSString *)userId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    
    WEAK(self);
    
    [HttpManager whiteBoardStateWithValue:value appId:appId roomId:roomId userId:userId apiVersion:apiVersion completeSuccessBlock:successBlock completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil){
           failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)sendCoVideoWithType:(SignalLinkState)linkState userIds:(NSArray<NSString *> *)userIds apiversion:(NSString *)apiversion successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    if(linkState == SignalLinkStateIdle) {
        return;
    }
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    WEAK(self);
    [HttpManager sendCoVideoWithType:linkState appId:appId roomId:roomId userIds:userIds apiVersion:apiversion successBolck:^{
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil) {
            failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)hostActionWithType:(EnableSignalType)type value:(NSInteger)value userId:(NSString *)userId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;

    WEAK(self);
    [HttpManager hostActionWithType:type value:value appId:appId roomId:roomId userId:userId apiVersion:apiVersion completeSuccessBlock:successBlock completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil) {
            failBlock([weakself httpErrorMessage:error]);
        }
    }];
}
- (void)audienceActionWithType:(EnableSignalType)type value:(NSInteger)value userId:(NSString *)userId apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;

    WEAK(self);
    [HttpManager audienceActionWithType:type value:value appId:appId roomId:roomId userId:userId apiVersion:apiVersion completeSuccessBlock:successBlock completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil) {
            failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)uploadLogWithApiversion:(NSString *)apiversion successBlock:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    WEAK(self);
    
    [LogManager uploadLogWithSceneType:self.sceneType appId:appId roomId:roomId apiVersion:apiversion completeSuccessBlock:^(NSString * _Nonnull uploadSerialNumber) {
        if(successBlock != nil){
           successBlock(uploadSerialNumber);
        }
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil){
           failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)getWhiteInfoWithApiversion:(NSString *)apiversion successBlock:(void (^ _Nullable) (WhiteInfoModel * model))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    WEAK(self);
    [HttpManager getWhiteInfoWithAppId:appId roomId:roomId apiVersion:apiversion completeSuccessBlock:^(WhiteInfoModel * _Nonnull model) {
        if(successBlock != nil){
           successBlock(model);
        }
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil){
           failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)getReplayInfoWithRecordId:(NSString*)recordId apiversion:(NSString *)apiversion successBlock:(void (^ _Nullable) (ReplayInfoModel * model))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    WEAK(self);
    [HttpManager getReplayInfoWithAppId:appId roomId:roomId recordId:recordId apiVersion:apiversion completeSuccessBlock:^(ReplayInfoModel * _Nonnull model) {
        
        model.boardId = self.baseConfigModel.boardId;
        model.boardToken = self.baseConfigModel.boardToken;
        if(successBlock != nil){
           successBlock(model);
        }
        
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil){
           failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)leftRoomWithUserId:(NSString *)userId apiversion:(NSString *)apiversion successBolck:(void (^ _Nullable)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    WEAK(self);
    [HttpManager leftRoomWithAppId:appId roomId:roomId userId:userId apiVersion:apiversion  successBolck:^{
        if(successBlock != nil){
           successBlock();
        }
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil){
           failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (int)submitRating:(NSInteger)rating {
    NSString *callId = [self.rtcManager getCallId];
    return [self.rtcManager rate:callId rating:rating description:@""];
}

- (int)switchCamera {
    return [self.rtcManager switchCamera];
}

- (void)releaseResource {
    
    for (VideoSessionModel *model in self.rtcVideoSessionModels){
        model.videoCanvas.view = nil;
        if(model.uid == self.baseConfigModel.uid) {
            [self.rtcManager setupLocalVideo:model.videoCanvas];
        } else {
            [self.rtcManager setupRemoteVideo:model.videoCanvas];
        }
    }
    [self.rtcVideoSessionModels removeAllObjects];
    
    [self.rtmManager releaseSignalResources];
    [self.rtcManager releaseRTCResources];

    self.rtcVideoSessionModels = [NSMutableArray array];
}

- (void)dealloc {
    [self releaseResource];
}

#pragma mark EnterClassProcess
- (void)getConfigWithApiVersion:(NSString*)apiVersion successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    if(self.baseConfigModel.multiLanguage != nil){
        if(successBlock != nil){
           successBlock();
        }
        return;
    }

    WEAK(self);
    [HttpManager getConfigWithApiVersion:apiVersion successBolck:^(ConfigAllInfoModel * _Nonnull model) {
        
        weakself.baseConfigModel.multiLanguage = model.configInfoModel.multiLanguage;
        if(successBlock != nil){
            successBlock();
        }
        
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil) {
            failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)getEntryInfoWithParams:(EntryParams *)params apiVersion:(NSString *)apiVersion successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {

    WEAK(self);
    [HttpManager enterRoomWithParams:params appId:self.baseConfigModel.appId apiVersion:apiVersion successBolck:^(EnterRoomInfoModel * _Nonnull model) {
        
        if(weakself.sceneType == SceneTypeEducation || weakself.sceneType == SceneTypeConference){
            weakself.baseConfigModel.userToken = model.userToken;
            weakself.baseConfigModel.roomId = model.roomId;
        } else {
            weakself.baseConfigModel.userToken = model.user.userToken;
            weakself.baseConfigModel.roomId = model.room.roomId;
        }

        if(successBlock != nil){
            successBlock();
        }
        
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil) {
            failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)getRoomInfoWithApiversion:(NSString *)apiversion successBlock:(void (^)(id roomInfoModel))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;

    WEAK(self);
    [HttpManager getRoomInfoWithAppId:appId roomId:roomId apiVersion:apiversion completeSuccessBlock:^(id _Nonnull responseModel) {
        if(successBlock != nil){
            successBlock(responseModel);
        }
    } completeFailBlock:^(NSError * _Nonnull error) {
       if(failBlock != nil) {
           failBlock([weakself httpErrorMessage:error]);
       }
    }];
}

- (void)updateRoomInfoWithValue:(NSInteger)value enableSignalType:(ConfEnableRoomSignalType)type apiversion:(NSString *)apiversion successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    
    NSString *appId = self.baseConfigModel.appId;
    NSString *roomId = self.baseConfigModel.roomId;
    [HttpManager updateRoomInfoWithValue:value enableSignalType:type appId:appId roomId:roomId apiVersion:APIVersion1 completeSuccessBlock:^{
        if(successBlock != nil){
            successBlock();
        }
    } completeFailBlock:^(NSError * _Nonnull error) {
        if(failBlock != nil){
           failBlock([weakself httpErrorMessage:error]);
        }
    }];
}

- (void)setupRTMWithSuccessBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock{

    NSString *appid = self.baseConfigModel.appId;
    NSString *appToken = self.baseConfigModel.rtmToken;
    NSString *uid = @(self.baseConfigModel.uid).stringValue;

    self.rtmManager = [RTMManager new];
    WEAK(self);
    [self.rtmManager initSignalWithAppid:appid appToken:appToken userId:uid dataSourceDelegate:self completeSuccessBlock:^{
        
        NSString *channelName = self.baseConfigModel.channelName;
        [weakself.rtmManager joinSignalWithChannelName:channelName completeSuccessBlock:^{
            if(successBlock != nil){
               successBlock();
            }
        } completeFailBlock:failBlock];
    } completeFailBlock:failBlock];
}
- (void)setupRTCWithClientRole:(ClientRole)role successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    AgoraClientRole agoraClientRole = AgoraClientRoleAudience;
    if (role == ClientRoleAudience) {
        agoraClientRole = AgoraClientRoleAudience;
    } else if(role == ClientRoleBroadcaster) {
        agoraClientRole = AgoraClientRoleBroadcaster;
    }
    
    BaseConfigModel *configModel = self.baseConfigModel;
    self.rtcManager = [RTCManager new];
    [self.rtcManager initEngineKitWithAppid:configModel.appId clientRole:agoraClientRole dataSourceDelegate:self];
    
    int errorCode = [self.rtcManager joinChannelByToken:configModel.rtcToken channelId:configModel.channelName info:nil uid:configModel.uid joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
        AgoraLogInfo(@"join rtc success");
        
        if(successBlock != nil){
           successBlock();
        }
    }];
    if(errorCode != 0){
        AgoraLogInfo(@"join rtc fail:%d", errorCode);
        if(failBlock != nil){
           failBlock(errorCode);
        }
    }
}

#pragma mark mute media
- (void)muteLocalAudioStream:(NSNumber *)mute {
    [self.rtcManager muteLocalAudioStream:mute.boolValue];
}
- (void)muteLocalVideoStream:(NSNumber *)mute {
    [self.rtcManager muteLocalVideoStream:mute.boolValue];
}

#pragma mark Private Http Describe
- (NSError *)httpErrorMessage:(NSError *)error {
    
    NSInteger errorCode = error.code;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray<NSString*> *allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [allLanguages objectAtIndex:0];
    NSString *msg = @"";
    if([preferredLang containsString:@"zh-Hans"]) {
        msg = [self.baseConfigModel.multiLanguage.cn valueForKey:@(errorCode).stringValue];
    } else {
        msg = [self.baseConfigModel.multiLanguage.en valueForKey:@(errorCode).stringValue];
    }
    if(msg == nil || msg.length == 0) {
        msg = error.localizedDescription;
    }
    
    NSError *localError = LocalError(errorCode, msg);
    return localError;
}


@end
