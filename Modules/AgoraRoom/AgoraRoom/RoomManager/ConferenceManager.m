//
//  ConferenceManager.m
//  AgoraRoom
//
//  Created by SRS on 2020/5/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ConferenceManager.h"
#import "RoomManager.h"
#import "ConfConfigModel.h"
#import "JsonParseUtil.h"
#import <YYModel.h>

#import "ConfSignalChannelHostModel.h"
#import "LogManager.h"

#define CONF_MESSAGE_VERSION 1
#define ConfNoNullString(x) ((x == nil) ? @"" : x)
#define ConfNoNullNumber(x) ((x == nil) ? @(0) : x)
#define ConfNoNullArray(x) ((x == nil) ? ([NSArray array]) : x)

@interface ConferenceManager ()<RoomManagerDelegate>

@property (nonatomic, strong) RoomManager *roomManager;
@property (nonatomic, assign) SceneType sceneType;
@property (nonatomic, copy) void (^ netWorkProbeTestBlock) (NetworkGrade grade);

// 在成功获取所有人数据 之前的人员进出Models
@property (nonatomic, strong) NSMutableArray<ConfSignalChannelInOutInfoModel*> *recordInOutInfoModels;
@property (nonatomic, assign) BOOL hasAllUserModels;

@end

@implementation ConferenceManager
- (instancetype)init {
    NSAssert(1 == 0, @"init must use: initWithSceneType");
    return self;
}

- (instancetype)initWithSceneType:(SceneType)type appId:(NSString *)appId authorization:(NSString *)authorization {
    if (self = [super init]) {
        self.sceneType = type;
        ConfConfigModel.shareInstance.appId = appId;
        self.roomManager = [[RoomManager alloc] initWithSceneType:type appId:appId authorization:authorization configModel:ConfConfigModel.shareInstance];
        self.roomManager.delegate = self;
        
        self.hasAllUserModels = NO;
        self.recordInOutInfoModels = [NSMutableArray array];
    }
    
    return self;
}

- (void)netWorkProbeTestCompleteBlock:(void (^ _Nullable) (NetworkGrade grade))block {
    NSAssert(ConfConfigModel.shareInstance.appId != nil, @"initWithSceneType fisrt");
    [self.roomManager startNetWorkProbeTest:ConfConfigModel.shareInstance.appId];
    self.netWorkProbeTestBlock = block;
}

// init media
- (void)initMediaWithClientRole:(ClientRole)role successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    WEAK(self);
    [self.roomManager initMediaWithClientRole:role successBolck:^{
        
        BOOL muteAudio = !weakself.ownModel.enableAudio;
        [weakself.roomManager muteLocalAudioStream:@(muteAudio)];
        
        BOOL muteVideo = !weakself.ownModel.enableVideo;
        [weakself.roomManager muteLocalVideoStream:@(muteVideo)];
        
        if(successBlock != nil){
            successBlock();
        }
        
    } failBlock:failBlock];
}

- (void)entryConfRoomWithParams:(ConferenceEntryParams *)params successBolck:(void (^ )(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    ConfConfigModel.shareInstance.userName = params.userName;
    ConfConfigModel.shareInstance.roomName = params.roomName;
    ConfConfigModel.shareInstance.password = params.password;
    ConfConfigModel.shareInstance.enableVideo = params.enableVideo;
    ConfConfigModel.shareInstance.enableAudio = params.enableAudio;
    ConfConfigModel.shareInstance.avatar = params.avatar;
    
    WEAK(self);
    [self.roomManager enterRoomProcess:params configApiVersion:APIVersion1 entryApiVersion:APIVersion1 roomInfoApiVersion:APIVersion1 successBolck:^(id  _Nonnull roomInfoModel) {
        if([roomInfoModel isKindOfClass:[ConfRoomInfoModel class]]) {
            ConfRoomInfoModel *model = (ConfRoomInfoModel*)roomInfoModel;
            [weakself handelConfRoomInfoModel:model];
            if(successBlock != nil){
                successBlock();
            }
        }
    } failBlock:failBlock];
}

- (void)getConfRoomInfoWithSuccessBlock:(void (^)(ConfRoomInfoModel *roomInfoModel))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    [self.roomManager getRoomInfoWithApiversion:APIVersion1 successBlock:^(id roomInfoModel) {
        
        if([roomInfoModel isKindOfClass:[ConfRoomInfoModel class]]) {
            ConfRoomInfoModel *model = (ConfRoomInfoModel*)roomInfoModel;
            [weakself handelConfRoomInfoModel:model];
            if(successBlock != nil){
                successBlock(model);
            }
        }
    } failBlock:failBlock];
}

- (void)p2pActionWithType:(EnableSignalType)type actionType:(P2PMessageTypeAction)actionType userId:(NSString *)userId completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    if(actionType == P2PMessageTypeActionInvitation || actionType == P2PMessageTypeActionRejectApply) {
        
        NSInteger value = actionType == P2PMessageTypeActionInvitation ? 1 : 2;
        
        [self.roomManager hostActionWithType:type value:value userId:userId apiVersion:APIVersion1 completeSuccessBlock:successBlock completeFailBlock:failBlock];
        
    } else if(actionType == P2PMessageTypeActionApply || actionType == P2PMessageTypeActionRejectInvitation) {
        
        NSInteger value = actionType == P2PMessageTypeActionApply ? 1 : 2;
        
        [self.roomManager audienceActionWithType:type value:value userId:userId apiVersion:APIVersion1 completeSuccessBlock:successBlock completeFailBlock:failBlock];
    }
}

- (void)uploadLogWithSuccessBlock:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    [self.roomManager uploadLogWithApiversion:APIVersion1 successBlock:successBlock failBlock:failBlock];
}

- (void)updateRoomInfoWithValue:(NSInteger)value enableSignalType:(ConfEnableRoomSignalType)type successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    [self.roomManager updateRoomInfoWithValue:value enableSignalType:type apiversion:APIVersion1 successBolck:^{
        
        switch (type) {
            case ConfEnableRoomSignalTypeMuteAllAudio:
                weakself.roomModel.muteAllAudio = value;
                if(value != MuteAllAudioStateUnmute) {
                    for(ConfUserModel *userModel in self.userListModels){
                        if(userModel.role != ConfRoleTypeHost){
                            if(userModel.uid == weakself.ownModel.uid && userModel.enableAudio) {
                                
                                BOOL muteAudio = YES;
                                [weakself.roomManager muteLocalAudioStream:@(muteAudio)];
                            }
                            userModel.enableAudio = NO;
                        }
                    }
                }
                break;
            case ConfEnableRoomSignalTypeMuteAllChat:
                weakself.roomModel.muteAllChat = value;
                break;
            case ConfEnableRoomSignalTypeShareBoard:
                weakself.roomModel.shareBoard = value;
                break;
            case ConfEnableRoomSignalTypeState:
                break;
            default:
                break;
        }
        
        if(successBlock != nil){
            successBlock();
        }
        
    } failBlock:failBlock];
}

// get user list info
- (void)getUserListWithSuccessBlock:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    [self getUserListWithNextId:@"0" userModelList:@[] successBlock:^(NSArray<ConfUserModel *> *models) {
        
        NSMutableArray<ConfUserModel *> *allUserListModel = [NSMutableArray arrayWithObject:weakself.ownModel];
        for(ConfUserModel *userModel in self.roomModel.hosts) {
            if(userModel.uid != weakself.ownModel.uid){
                [allUserListModel addObject:userModel];
            }
        }
        [allUserListModel addObjectsFromArray:models];
        weakself.userListModels = [NSArray arrayWithArray:allUserListModel];
        if (successBlock != nil) {
            successBlock();
        }
    } failBlock:failBlock];
}
- (void)getUserListWithNextId:(NSString *)nextId userModelList:(NSArray<ConfUserModel*>*)userModelList successBlock:(void (^)(NSArray<ConfUserModel*> *models))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    [self.roomManager getUserListWithNextId:nextId count:100 apiversion:APIVersion1 successBlock:^(ConfUserListInfoModel * _Nonnull userListInfoModel) {
        
        NSMutableArray<ConfUserModel*> *userList = [NSMutableArray array];
        [userList addObjectsFromArray:userModelList];
        [userList addObjectsFromArray:userListInfoModel.list];
        
        if(userListInfoModel.total > userList.count){
            [weakself getUserListWithNextId:userListInfoModel.nextId userModelList:userList successBlock:successBlock failBlock:failBlock];
        } else {
            weakself.hasAllUserModels = YES;
            [weakself handleInOutModels:weakself.recordInOutInfoModels];
            successBlock(userList);
        }
        
    } failBlock:failBlock];
}

//  update users info
- (void)updateUserInfoWithUserId:(NSString*)userId value:(BOOL)enable enableSignalType:(EnableSignalType)type successBolck:(void (^)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    [self.roomManager updateUserInfoWithUserId:userId value:enable enableSignalType:type apiversion:APIVersion1 successBolck:^{
        
        for(ConfUserModel *model in weakself.userListModels) {
            if([model.userId isEqualToString:userId]){
                // 更新数据
                if(type == EnableSignalTypeChat){
                    model.enableChat = enable;
                } else if(type == EnableSignalTypeAudio){
                    model.enableAudio = enable;
                    if([model.userId isEqualToString:weakself.ownModel.userId]) {
                        [weakself.roomManager muteLocalAudioStream:@(!enable)];
                    }
                } else if(type == EnableSignalTypeVideo){
                    model.enableVideo = enable;
                    if([model.userId isEqualToString:weakself.ownModel.userId]) {
                        [weakself.roomManager muteLocalVideoStream:@(!enable)];
                    }
                }
                break;
            }
        }
        if (successBlock != nil) {
            successBlock();
        }
        
    } failBlock:failBlock];
}

- (void)changeHostWithUserId:(NSString *)userId completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {

    [self.roomManager changeHostWithUserId:userId completeSuccessBlock:^{

        if (successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}

//  update white state
- (void)whiteBoardStateWithValue:(BOOL)enable userId:(NSString *)userId  completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    [self.roomManager whiteBoardStateWithValue:enable userId:userId apiVersion:APIVersion1 completeSuccessBlock:^{
        
        for(ConfUserModel *model in weakself.userListModels) {
            if([model.userId isEqualToString:userId]){
                model.grantBoard = enable;
                break;
            }
        }
        
        if (successBlock != nil) {
            successBlock();
        }
        
    } completeFailBlock:failBlock];
}

// send message
- (void)sendMessageWithText:(NSString *)message successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    [self.roomManager sendMessageWithText:message apiversion:APIVersion1 successBolck:successBlock completeFailBlock:failBlock];
}

- (void)leftRoomWithUserId:(NSString *)userId successBolck:(void (^ _Nullable)(void))successBlock failBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    WEAK(self);
    [self.roomManager leftRoomWithUserId:userId apiversion:APIVersion1 successBolck:^{
        
        NSMutableArray<ConfUserModel *> *_userListModels = [NSMutableArray array];
        
        if(![userId isEqualToString: weakself.ownModel.userId]) {
            
            for(ConfUserModel *model in weakself.userListModels) {
                if([model.userId isEqualToString:userId]){
                    continue;
                }
                
                [_userListModels addObject:model];
            }
        }
        weakself.userListModels = [NSArray arrayWithArray:_userListModels];
        
        if (successBlock != nil) {
            successBlock();
        }
        
    } failBlock:failBlock];
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
    self.ownModel = nil;
    self.roomModel = nil;
    
    self.hasAllUserModels = NO;
    self.recordInOutInfoModels = [NSMutableArray array];
}

#pragma mark private
- (void)handelConfRoomInfoModel:(ConfRoomInfoModel *)roomInfoModel {
    
    ConfConfigModel.shareInstance.uid = roomInfoModel.localUser.uid;
    ConfConfigModel.shareInstance.userId = roomInfoModel.localUser.userId;
    ConfConfigModel.shareInstance.roomName = roomInfoModel.room.roomName;
    ConfConfigModel.shareInstance.rtmToken = roomInfoModel.localUser.rtmToken;
    ConfConfigModel.shareInstance.rtcToken = roomInfoModel.localUser.rtcToken;
    ConfConfigModel.shareInstance.channelName = roomInfoModel.room.channelName;
    
    self.roomModel = roomInfoModel.room;
    self.ownModel = roomInfoModel.localUser;
}

// Canvas
- (void)addVideoCanvasWithUId:(NSUInteger)uid inView:(UIView *)view showType:(ShowViewType)showType {
    [self.roomManager addVideoCanvasWithUId:uid inView:view showType:showType];
}
- (void)addVideoCanvasWithUId:(NSUInteger)uid inView:(UIView *)view {
    [self.roomManager addVideoCanvasWithUId:uid inView:view showType:ShowViewTypeHidden];
}
- (void)removeVideoCanvasWithUId:(NSUInteger)uid {
    [self.roomManager removeVideoCanvasWithUId:uid];
}
- (void)removeVideoCanvasWithView:(UIView *)view {
    [self.roomManager removeVideoCanvasWithView:view];
}

#pragma mark RoomManagerDelegate
- (void)didReceivedSignal:(NSString *)signalText fromPeer:(NSString *)peer {
    NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:signalText];
    ConfSignalP2PModel *model = [ConfSignalP2PModel yy_modelWithDictionary:dict];
    ConfSignalP2PInfoModel *infoModel = model.data;
    if(model.cmd == P2PMessageTypeInvitation) {
        NSInteger action = infoModel.action;
        if(action == 1){
            infoModel.action = P2PMessageTypeActionInvitation;
        } else if(action == 2) {
            infoModel.action = P2PMessageTypeActionRejectApply;
        }
    } else if(model.cmd == P2PMessageTypeApply) {
        NSInteger action = infoModel.action;
        if(action == 1){
            infoModel.action = P2PMessageTypeActionApply;
        } else if(action == 2) {
            infoModel.action = P2PMessageTypeActionRejectInvitation;
        }
    } else if(model.cmd == P2PMessageTypeTip) {
        NSInteger action = infoModel.action;
        if(action == 1){
            infoModel.action = P2PMessageTypeActionOpenTip;
        } else if(action == 0) {
            infoModel.action = P2PMessageTypeActionCloseTip;
        }
    }
    if([self.delegate respondsToSelector:@selector(didReceivedPeerSignal:)]) {
        [self.delegate didReceivedPeerSignal:infoModel];
    }
}
- (void)didReceivedSignal:(NSString *)signalText {
    
    NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:signalText];
    NSInteger cmd = [dict[@"cmd"] integerValue];
    NSInteger version = [dict[@"version"] integerValue];
    if(version != CONF_MESSAGE_VERSION) {
        return;
    }
    
    if(cmd == ChannelMessageTypeChat) {
        
        [self messageChat:dict];
        
    } else if(cmd == ChannelMessageTypeInOut) {
        
        [self messageInOut:dict];
        
    } else if(cmd == ChannelMessageTypeRoomInfo) {
        
        [self messageRoomInfo:dict];
        
    } else if(cmd == ChannelMessageTypeUserInfo) {
        
        [self messageUserInfo:dict];
        
    } else if(cmd == ChannelMessageTypeShareBoard) {
        
        [self messageShareBoard:dict];
        
    } else if(cmd == ChannelMessageTypeShareScreen) {
        
        [self messageShareScreen:dict];
        
    } else if(cmd == ChannelMessageTypeHostChange) {
        
        [self messageHostChange:dict];
        
    } else if(cmd == ChannelMessageTypeKickoff) {
        
        [self messageKickoff:dict];
    }
}

- (void)didReceivedMessage:(MessageInfoModel * _Nonnull)model {
    if([self.delegate respondsToSelector:@selector(didReceivedMessage:)]) {
        [self.delegate didReceivedMessage:model];
    }
}
- (void)didReceivedConnectionStateChanged:(ConnectionState)state {
    if([self.delegate respondsToSelector:@selector(didReceivedConnectionStateChanged:)]) {
        [self.delegate didReceivedConnectionStateChanged:ConnectionStateReconnected];
    }
}
- (void)didAudioRouteChanged:(AudioOutputRouting)routing {
    if([self.delegate respondsToSelector:@selector(didAudioRouteChanged:)]) {
        [self.delegate didAudioRouteChanged: routing];
    }
}
- (void)networkLastmileTypeGrade:(NetworkGrade)grade {
    if(self.netWorkProbeTestBlock != nil){
        self.netWorkProbeTestBlock(grade);
    }
}
- (void)networkTypeGrade:(NetworkGrade)grade uid:(NSInteger)uid {
    if([self.delegate respondsToSelector:@selector(networkTypeGrade:uid:)]) {
        [self.delegate networkTypeGrade:grade uid: uid];
    }
}

#pragma mark Handle message
- (void)messageChat:(NSDictionary *)dict {
    
    MessageInfoModel *model = [MessageModel yy_modelWithDictionary:dict].data;
    if(![model.userId isEqualToString:self.ownModel.userId]) {
        model.isSelfSend = NO;
        NSNumber *timestamp = dict[@"timestamp"];
        model.timestamp = ConfNoNullNumber(timestamp).integerValue;
        
        if([self.delegate respondsToSelector:@selector(didReceivedMessage:)]) {
            [self.delegate didReceivedMessage:model];
        }
    }
}
- (void)messageInOut:(NSDictionary *)dict {
    
    NSDictionary *dataDic = dict[@"data"];
    if(dataDic == nil){
        return;
    }
        
    ConfSignalChannelInOutModel *inOutModel = [ConfSignalChannelInOutModel yy_modelWithDictionary:dataDic];
    
    if(!self.hasAllUserModels) {
        [self.recordInOutInfoModels addObjectsFromArray:inOutModel.list];
        return;
    }
    
    self.roomModel.onlineUsers = inOutModel.total;
    [self handleInOutModels:inOutModel.list];
    AgoraLogInfo(@"messageInOut ownModel ===> %@", [self.ownModel yy_modelDescription]);
    AgoraLogInfo(@"messageShareBoard roomModel ===> %@", [self.roomModel yy_modelDescription]);
    AgoraLogInfo(@"messageInOut userListModels ===> %@", [self.userListModels yy_modelDescription]);
    
    if([self.delegate respondsToSelector:@selector(didReceivedSignalInOut:)]) {
        [self.delegate didReceivedSignalInOut: inOutModel.list];
    }
}
- (void)messageUserInfo:(NSDictionary *)dict {
    NSDictionary *dataDic = dict[@"data"];
    if(dataDic == nil){
        return;
    }
    
    ConfUserModel *userModel = [ConfUserModel yy_modelWithDictionary:dataDic];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", userModel.uid];
    NSArray<ConfUserModel *> *filteredArray = [self.userListModels filteredArrayUsingPredicate:predicate];
    if(filteredArray > 0){
        filteredArray.firstObject.userName = userModel.userName;
        filteredArray.firstObject.role = userModel.role;
        filteredArray.firstObject.enableChat = userModel.enableChat;
        filteredArray.firstObject.enableVideo = userModel.enableVideo;
        filteredArray.firstObject.enableAudio = userModel.enableAudio;
    }
    
    BOOL muteAudio = !self.ownModel.enableAudio;
    [self.roomManager muteLocalAudioStream:@(muteAudio)];
    
    BOOL muteVideo = !self.ownModel.enableVideo;
    [self.roomManager muteLocalVideoStream:@(muteVideo)];
    
    AgoraLogInfo(@"messageUserInfo ownModel ===> %@", [self.ownModel yy_modelDescription]);
    AgoraLogInfo(@"messageShareBoard roomModel ===> %@", [self.roomModel yy_modelDescription]);
    AgoraLogInfo(@"messageUserInfo userListModels ===> %@", [self.userListModels yy_modelDescription]);
    
    if([self.delegate respondsToSelector:@selector(didReceivedSignalUserInfo:)]) {
        [self.delegate didReceivedSignalUserInfo: userModel];
    }
}
- (void)messageRoomInfo:(NSDictionary *)dict {
    
    NSDictionary *dataDic = dict[@"data"];
    if(dataDic == nil) {
        return;
    }
    
    ConfSignalChannelRoomModel *model = [ConfSignalChannelRoomModel yy_modelWithDictionary:dataDic];
    
    self.roomModel.muteAllAudio = model.muteAllAudio;
    if(model.muteAllAudio != MuteAllAudioStateUnmute){
        for(ConfUserModel *userModel in self.userListModels){
            if(userModel.role != ConfRoleTypeHost){
                userModel.enableAudio = NO;
            }
        }
    }
    
    if(!self.ownModel.enableAudio) {
        [self.roomManager muteLocalAudioStream:@(1)];
    }
    
    AgoraLogInfo(@"messageRoomInfo ownModel ===> %@", [self.ownModel yy_modelDescription]);
    AgoraLogInfo(@"messageShareBoard roomModel ===> %@", [self.roomModel yy_modelDescription]);
    AgoraLogInfo(@"messageRoomInfo userListModels ===> %@", [self.userListModels yy_modelDescription]);
    
    if([self.delegate respondsToSelector:@selector(didReceivedSignalRoomInfo:)]) {
        [self.delegate didReceivedSignalRoomInfo:model];
    }
}
- (void)messageShareBoard:(NSDictionary *)dict {
    
    NSDictionary *dataDic = dict[@"data"];
    if(dataDic == nil) {
        return;
    }
    
    ConfSignalChannelBoardModel *boardModel = [ConfSignalChannelBoardModel yy_modelWithDictionary:dataDic];
    self.roomModel.shareBoard = boardModel.shareBoard;
    self.roomModel.createBoardUserId = boardModel.createBoardUserId;
    if (boardModel.shareBoard == 0) {
        self.roomModel.shareBoardUsers = @[];
    } else {
        self.roomModel.shareBoardUsers = [NSArray arrayWithArray: boardModel.shareBoardUsers];
    }
    
    for(ConfUserModel *userModel in self.userListModels) {
        BOOL share = NO;
        for(ConfShareBoardUserModel *shareBoardUserModel in self.roomModel.shareBoardUsers) {
            if(userModel.uid == shareBoardUserModel.uid){
                share = YES;
                break;
            }
        }
        userModel.grantBoard = share;
    }
    
    AgoraLogInfo(@"messageShareBoard ownModel ===> %@", [self.ownModel yy_modelDescription]);
    AgoraLogInfo(@"messageShareBoard roomModel ===> %@", [self.roomModel yy_modelDescription]);
    AgoraLogInfo(@"messageShareBoard userListModels ===> %@", [self.userListModels yy_modelDescription]);
    
    if([self.delegate respondsToSelector:@selector(didReceivedSignalShareBoard:)]) {
        [self.delegate didReceivedSignalShareBoard:boardModel];
    }
}
- (void)messageShareScreen:(NSDictionary *)dict {
    NSDictionary *dataDic = dict[@"data"];
    if(dataDic == nil) {
        return;
    }
    
    ConfSignalChannelScreenModel *screenModel = [ConfSignalChannelScreenModel yy_modelWithDictionary:dataDic];
    self.roomModel.shareScreen = screenModel.shareScreen;
    
    if (screenModel.shareScreen == 0) {
        
        self.roomModel.shareScreenUsers = @[];
        
    } else {
        
        self.roomModel.shareScreenUsers = [NSArray arrayWithArray: screenModel.shareScreenUsers];
    }
    
    for(ConfUserModel *userModel in self.userListModels) {
        BOOL share = NO;
        for(ConfShareScreenUserModel *shareScreenUserModel in self.roomModel.shareScreenUsers) {
            if(userModel.uid == shareScreenUserModel.uid){
                share = YES;
                break;
            }
        }
        userModel.grantScreen = share;
    }
    
    AgoraLogInfo(@"messageShareScreen ownModel ===> %@", [self.ownModel yy_modelDescription]);
    AgoraLogInfo(@"messageShareBoard roomModel ===> %@", [self.roomModel yy_modelDescription]);
    AgoraLogInfo(@"messageShareScreen userListModels ===> %@", [self.userListModels yy_modelDescription]);
    
    if([self.delegate respondsToSelector:@selector(didReceivedSignalShareScreen:)]) {
        [self.delegate didReceivedSignalShareScreen:screenModel];
    }
}
- (void)messageHostChange:(NSDictionary *)dict {
    
    // init
    NSArray<ConfUserModel*> *allHostModels = [ConfSignalChannelHostModel yy_modelWithDictionary:dict].data;
    [self hostChange:allHostModels];
    
    AgoraLogInfo(@"messageHostChange ownModel ===> %@", [self.ownModel yy_modelDescription]);
    AgoraLogInfo(@"messageShareBoard roomModel ===> %@", [self.roomModel yy_modelDescription]);
    AgoraLogInfo(@"messageHostChange userListModels ===> %@", [self.userListModels yy_modelDescription]);
    
    if([self.delegate respondsToSelector:@selector(didReceivedSignalHostChange:)]) {
        [self.delegate didReceivedSignalHostChange:allHostModels];
    }
}

- (void)messageKickoff:(NSDictionary *)dict {
    
    NSDictionary *dataDic = dict[@"data"];
    if(dataDic == nil) {
        return;
    }
    
    ConfSignalChannelKickoutModel *model = [ConfSignalChannelKickoutModel yy_modelWithDictionary:dataDic];
    if(![model.userId isEqualToString:self.ownModel.userId]) {
        return;
    }
    
    [self.roomManager leftRoomWithUserId:model.userId apiversion:APIVersion1 successBolck:nil failBlock:nil];
    
    AgoraLogInfo(@"messageKickoff ownModel ===> %@", [self.ownModel yy_modelDescription]);
    AgoraLogInfo(@"messageShareBoard roomModel ===> %@", [self.roomModel yy_modelDescription]);
    AgoraLogInfo(@"messageKickoff userListModels ===> %@", [self.userListModels yy_modelDescription]);
    
    if([self.delegate respondsToSelector:@selector(didReceivedSignalKickoutChange:)]) {
        [self.delegate didReceivedSignalKickoutChange:model];
    }
}

- (void)hostChange:(NSArray<ConfUserModel*> *)allHostModels {
        
    // remove no exsit
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state != 0"];
        allHostModels = [allHostModels filteredArrayUsingPredicate:predicate];
    }

    {
        NSPredicate *isSelfPredicate = [NSPredicate predicateWithFormat:@"uid == %d", self.ownModel.uid];
        NSArray<ConfUserModel*> *selfModels = [allHostModels filteredArrayUsingPredicate:isSelfPredicate];
        if(selfModels.count > 0){
            ConfUserModel *um = selfModels.firstObject;
            self.ownModel.userName = um.userName;
            self.ownModel.role = um.role;
            self.ownModel.enableChat = um.enableChat;
            self.ownModel.enableVideo = um.enableVideo;
            self.ownModel.enableAudio = um.enableAudio;
            self.ownModel.grantBoard = um.grantBoard;
            self.ownModel.grantScreen = um.grantScreen;
        }
    }
    
    NSPredicate *currentPredicate = [NSPredicate predicateWithFormat:@"role == %d", ConfRoleTypeHost];
    NSArray<ConfUserModel*> *currentHostModels = [allHostModels filteredArrayUsingPredicate:currentPredicate];
    
    NSPredicate *originalPredicate = [NSPredicate predicateWithFormat:@"role == %d", ConfRoleTypeParticipant];
    NSArray<ConfUserModel*> *originalHostModels = [allHostModels filteredArrayUsingPredicate:originalPredicate];
    
    // participantModels
    NSMutableArray<ConfUserModel*> *allParticipantModels = [NSMutableArray arrayWithArray:self.userListModels];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"role != %d", ConfRoleTypeHost];
    NSArray<ConfUserModel*> *participantModels = [allParticipantModels filteredArrayUsingPredicate:predicate];
    // add old host
    participantModels = [participantModels arrayByAddingObjectsFromArray:originalHostModels];
    // remove new host
    if(currentHostModels.count > 0) {
        NSString *predicateText = @"";
        for(ConfUserModel *userModel in currentHostModels) {
            if(predicateText.length == 0){
                predicateText = [NSString stringWithFormat:@"uid != %d", userModel.uid];
            } else {
                predicateText = [predicateText stringByAppendingFormat:@"&& uid != %d", userModel.uid];
            }
        }
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:predicateText];
        participantModels = [participantModels filteredArrayUsingPredicate:predicate1];
    }
    // remove self
    NSPredicate *selfPredicate = [NSPredicate predicateWithFormat:@"uid != %d", self.ownModel.uid];
    participantModels = [participantModels filteredArrayUsingPredicate:selfPredicate];
    
    // host
    self.roomModel.hosts = [NSArray arrayWithArray:currentHostModels];
    NSPredicate *hostPredicate = [NSPredicate predicateWithFormat:@"uid != %d", self.ownModel.uid];
    NSArray<ConfUserModel*> *hostFilteredModels = [self.roomModel.hosts filteredArrayUsingPredicate:hostPredicate];
    
    NSMutableArray<ConfUserModel*> *allModels = [NSMutableArray array];
    [allModels addObject:self.ownModel];
    [allModels addObjectsFromArray:hostFilteredModels];
    [allModels addObjectsFromArray:participantModels];
    self.userListModels = [NSArray arrayWithArray:allModels];
    
    // role
    for(ConfUserModel *hostUserModel in self.roomModel.hosts) {
        
        for(ConfShareScreenUserModel *shareScreenUsers in self.roomModel.shareScreenUsers) {
            if(shareScreenUsers.uid == hostUserModel.uid){
                shareScreenUsers.role = ConfRoleTypeHost;
            } else {
                shareScreenUsers.role = ConfRoleTypeParticipant;
            }
        }
        
        for(ConfShareBoardUserModel *shareBoardUserModel in self.roomModel.shareBoardUsers) {
            if(shareBoardUserModel.uid == hostUserModel.uid){
                shareBoardUserModel.role = ConfRoleTypeHost;
            } else {
                shareBoardUserModel.role = ConfRoleTypeParticipant;
            }
        }
    }
}

- (void)handleInOutModels:(NSArray<ConfSignalChannelInOutInfoModel*> *) list {

    for (ConfSignalChannelInOutInfoModel *model in list){
        if(model.state == 0) { // out
            if(model.uid == self.ownModel.uid) {
                continue;
            }
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid != %d", model.uid];
            
            NSArray<ConfUserModel *> *filteredHostArray = [self.roomModel.hosts filteredArrayUsingPredicate:predicate];
            self.roomModel.hosts = [NSArray arrayWithArray:filteredHostArray];
            
            NSArray<ConfUserModel *> *filteredArray = [self.userListModels filteredArrayUsingPredicate:predicate];
            self.userListModels = [NSArray arrayWithArray:filteredArray];
            
            //  存储出去人的队列， 用于更新userListModels
            
        } else { // add
            NSPredicate *exsitPredicate = [NSPredicate predicateWithFormat:@"uid == %d", model.uid];
            NSArray<ConfUserModel *> *exsitFilteredArray = [self.userListModels filteredArrayUsingPredicate:exsitPredicate];
            if(exsitFilteredArray.count > 0) {
                
                ConfUserModel *um = exsitFilteredArray.firstObject;
                if(um.role == model.role || um.uid == self.ownModel.uid){
                    um.userName = model.userName;
                    um.enableChat = model.enableChat;
                    um.enableVideo = model.enableVideo;
                    um.enableAudio = model.enableAudio;
                    um.grantBoard = model.grantBoard;
                    um.grantScreen = model.grantScreen;
                    if(um.role == model.role) {
                       continue;
                    }
                    um.role = model.role;
                }
                
                // remove
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid != %d", um.uid];
                
                NSArray<ConfUserModel *> *filteredHostArray = [self.roomModel.hosts filteredArrayUsingPredicate:predicate];
                self.roomModel.hosts = [NSArray arrayWithArray:filteredHostArray];
                
                NSArray<ConfUserModel *> *filteredArray = [self.userListModels filteredArrayUsingPredicate:predicate];
                self.userListModels = [NSArray arrayWithArray:filteredArray];
            }
            
            // 添加
            if(model.role == ConfRoleTypeHost) {
                
                // host
                NSMutableArray<ConfUserModel *> *hosts = [NSMutableArray arrayWithArray:self.roomModel.hosts];
                [hosts addObject:model];
                self.roomModel.hosts = [NSArray arrayWithArray:hosts];
                NSPredicate *hostPredicate = [NSPredicate predicateWithFormat:@"uid != %d", self.ownModel.uid];
                NSArray<ConfUserModel*> *hostFilteredModels = [self.roomModel.hosts filteredArrayUsingPredicate:hostPredicate];
                
                NSMutableArray<ConfUserModel *> *userListModels = [NSMutableArray arrayWithArray:self.userListModels];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"role != %d && uid != %d", ConfRoleTypeHost, self.ownModel.uid];
                NSArray<ConfUserModel*> *participantModels = [userListModels filteredArrayUsingPredicate:predicate];
                
                NSMutableArray<ConfUserModel *> *_userListModels = [NSMutableArray arrayWithObject:self.ownModel];
                [_userListModels addObjectsFromArray:hostFilteredModels];
                [_userListModels addObjectsFromArray:participantModels];
                self.userListModels = [NSArray arrayWithArray:_userListModels];
                
            } else {
                
                NSMutableArray<ConfUserModel *> *userListModels = [NSMutableArray arrayWithArray:self.userListModels];
                [userListModels addObject:model];
                self.userListModels = [NSArray arrayWithArray:userListModels];
            }
        }
    }
}

@end
