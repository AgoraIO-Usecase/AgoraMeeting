//
//  EducationManager.m
//  AgoraRoom
//
//  Created by SRS on 2020/5/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EducationManager.h"
#import "RoomManager.h"
#import "EduConfigModel.h"

@interface EducationManager ()

@property (nonatomic, strong) RoomManager *roomManager;
@property (nonatomic, assign) SceneType sceneType;

@end

@implementation EducationManager
- (instancetype)init {
    NSAssert(1 == 0, @"inti must use: initWithSceneType");
    return self;
}

- (instancetype)initWithSceneType:(SceneType)type appId:(NSString *)appId authorization:(NSString *)authorization {
    if (self = [super init]) {
        self.coStudentModels = [NSArray array];
        self.sceneType = type;
        
        EduConfigModel.shareInstance.appId = appId;
        self.roomManager = [[RoomManager alloc] initWithSceneType:type appId:appId authorization:authorization configModel:EduConfigModel.shareInstance];
    }
    return self;
}

// init media
- (void)initMediaWithClientRole:(ClientRole)role successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    [self.roomManager initMediaWithClientRole:role successBolck:successBlock failBlock:failBlock];
}

- (void)entryEduRoomWithParams:(EduEntryParams *)params successBolck:(void (^ )(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    EduConfigModel.shareInstance.userName = params.userName;
    EduConfigModel.shareInstance.roomName = params.roomName;

    WEAK(self);
    [self.roomManager enterRoomProcess:params configApiVersion:APIVersion1 entryApiVersion:APIVersion1 roomInfoApiVersion:APIVersion1 successBolck:^(id  _Nonnull roomInfoModel) {
        if([roomInfoModel isKindOfClass:[EduRoomInfoModel class]]) {
            EduRoomInfoModel *model = (EduRoomInfoModel*)roomInfoModel;
            [weakself handelEduRoomInfoModel:model];
            if(successBlock != nil){
                successBlock();
            }
        }
    } failBlock:failBlock];
}

- (void)getEduRoomInfoWithSuccessBlock:(void (^)(EduRoomInfoModel *roomInfoModel))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    [self.roomManager getRoomInfoWithApiversion:APIVersion1 successBlock:^(id roomInfoModel) {
        
        if([roomInfoModel isKindOfClass:[EduRoomInfoModel class]]) {
            EduRoomInfoModel *model = (EduRoomInfoModel*)roomInfoModel;
            [weakself handelEduRoomInfoModel:model];
            if(successBlock != nil){
                successBlock(model);
            }
        }
    } failBlock:failBlock];
}

//  update users info
- (void)updateUserInfoWithValue:(BOOL)enable enableSignalType:(EnableSignalType)type successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *userId = EduConfigModel.shareInstance.userId;
    
    WEAK(self);
    [self.roomManager updateUserInfoWithUserId:userId value:enable enableSignalType:type apiversion:APIVersion1 successBolck:^{
        // 更新数据
        if(type == EnableSignalTypeChat){
            weakself.ownModel.enableChat = enable;
            for (EduUserModel *model in weakself.coStudentModels) {
                if(model.uid == weakself.ownModel.uid){
                    model.enableChat = enable;
                    break;
                }
            }
        } else if(type == EnableSignalTypeAudio){
            weakself.ownModel.enableAudio = enable;
            [weakself.roomManager muteLocalAudioStream:@(!enable)];
            for (EduUserModel *model in weakself.coStudentModels) {
                if(model.uid == weakself.ownModel.uid){
                    model.enableAudio = enable;
                    break;
                }
            }
        } else if(type == EnableSignalTypeVideo){
            weakself.ownModel.enableVideo = enable;
            [weakself.roomManager muteLocalVideoStream:@(!enable)];
            for (EduUserModel *model in weakself.coStudentModels) {
                if(model.uid == weakself.ownModel.uid){
                    model.enableVideo = enable;
                    break;
                }
            }
        }
    } failBlock:failBlock];
}

- (void)uploadLogWithSuccessBlock:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
   [self.roomManager uploadLogWithApiversion:APIVersion1 successBlock:successBlock failBlock:failBlock];
}

// send message
- (void)sendMessageWithText:(NSString *)message successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    [self.roomManager sendMessageWithText:message apiversion:APIVersion1 successBolck:successBlock completeFailBlock:failBlock];
}

- (void)leftRoomWithSuccessBolck:(void (^ _Nullable)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    [self.roomManager leftRoomWithUserId:self.ownModel.userId apiversion:APIVersion1 successBolck:successBlock failBlock:failBlock];
}

- (void)getWhiteInfoWithSuccessBlock:(void (^ _Nullable) (WhiteInfoModel * model))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    [self.roomManager getWhiteInfoWithApiversion:APIVersion1 successBlock:successBlock failBlock:failBlock];
}

- (NSInteger)submitRating:(NSInteger)rating {
    return [self.roomManager submitRating:rating];
}

- (NSInteger)switchCamera {
    return [self.roomManager switchCamera];
}

- (void)releaseResource {
    
    [self.roomManager leftRoomWithUserId:self.ownModel.userId apiversion:APIVersion1 successBolck:nil failBlock:nil];
    [self.roomManager releaseResource];
    
    self.hostModel = nil;
    self.ownModel = nil;
    self.roomModel = nil;
    self.shareScreenInfoModel = nil;
    
    self.coStudentModels = [NSArray array];
}

#pragma mark private
- (void)handelEduRoomInfoModel:(EduRoomInfoModel *)roomInfoModel {

    EduConfigModel.shareInstance.uid = roomInfoModel.localUser.uid;
    EduConfigModel.shareInstance.userId = roomInfoModel.localUser.userId;
    EduConfigModel.shareInstance.roomName = roomInfoModel.room.roomName;
    EduConfigModel.shareInstance.sceneType = roomInfoModel.room.type;
    EduConfigModel.shareInstance.rtmToken = roomInfoModel.localUser.rtmToken;
    EduConfigModel.shareInstance.rtcToken = roomInfoModel.localUser.rtcToken;
    EduConfigModel.shareInstance.channelName = roomInfoModel.room.channelName;
    
    self.roomModel = roomInfoModel.room;
    self.ownModel = roomInfoModel.localUser;

    NSMutableArray *array = [NSMutableArray array];
    if(self.roomModel != nil && self.roomModel.coVideoUsers != nil) {
       for(EduUserModel *userModel in self.roomModel.coVideoUsers) {
           if(userModel.role == UserRoleTypeTeacher) {
               self.hostModel = userModel;
           } else if(userModel.role == UserRoleTypeStudent) {
               [array addObject:userModel];
           }
       }
    }
    self.coStudentModels =  [NSArray arrayWithArray:array];
}

// Canvas
- (void)addVideoCanvasWithUId:(NSUInteger)uid inView:(UIView *)view {
    [self.roomManager addVideoCanvasWithUId:uid inView:view showType:ShowViewTypeHidden];
}
- (void)removeVideoCanvasWithUId:(NSUInteger)uid {
    [self.roomManager removeVideoCanvasWithUId:uid];
}
- (void)removeVideoCanvasWithView:(UIView *)view {
    [self.roomManager removeVideoCanvasWithView:view];
}

@end
