//
//  RoomManager+RTM.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import "RoomManager+RTM.h"
#import <AgoraRtmKit/AgoraRtmKit.h>
#import <objc/runtime.h>
#import <YYModel.h>

#import "JsonParseUtil.h"
#import "SignalP2PModel.h"
#import "SignalRoomModel.h"
#import "SignalUserModel.h"
#import "SignalReplayModel.h"

#import "NSArray+Copy.h"

#import "EntryParams.h"

static char *ReconnectKey = "ReconnectKey";

@implementation RoomManager (RTM)
@dynamic stratReconnect;

- (NSNumber *)stratReconnect{
    return objc_getAssociatedObject(self, ReconnectKey);
}

#pragma mark RTMManagerDelegate
- (void)didReceivedSignal:(NSString *)signalText fromPeer:(NSString *)peer {
    
    if([self.delegate respondsToSelector:@selector(didReceivedSignal:fromPeer:)]) {
        [self.delegate didReceivedSignal:signalText fromPeer:peer];
    }
    
//    NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:signalText];
//    SignalP2PInfoModel *model = [SignalP2PModel yy_modelWithDictionary:dict].data;
//
//    if([self.delegate respondsToSelector:@selector(didReceivedPeerSignal:)]) {
//        [self.delegate didReceivedPeerSignal:model];
//    }
}
- (void)didReceivedSignal:(NSString *)signalText {
    
    if([self.delegate respondsToSelector:@selector(didReceivedSignal:)]) {
        [self.delegate didReceivedSignal:signalText];
    }
    
//    NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:signalText];
//    NSInteger cmd = [dict[@"cmd"] integerValue];
//
//    if(cmd == MessageCmdTypeChat) {
//
//        [self messageChat:dict];
//
//    } else if(cmd == MessageCmdTypeRoomInfo) {
//
//        [self messageRoomInfo:dict];
//
//    } else if(cmd == MessageCmdTypeUserInfo) {
//
//        [self messageUserInfo:dict];
//
//    } else if(cmd == MessageCmdTypeReplay) {
//
//        [self messageReplay:dict];
//
//    } else if(cmd == MessageCmdTypeShareScreen) {
//
//        [self messageShareScreen:dict];
//    }
}
- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state {
    
    if(state == AgoraRtmConnectionStateConnected) {
        
        if(self.stratReconnect && self.stratReconnect.boolValue) {
            if([self.delegate respondsToSelector:@selector(didReceivedConnectionStateChanged:)]) {
                [self.delegate didReceivedConnectionStateChanged:ConnectionStateReconnected];
            }
        }
        objc_setAssociatedObject(self, ReconnectKey, @(0), OBJC_ASSOCIATION_COPY);
        
    } else if(state == AgoraRtmConnectionStateReconnecting) {
        objc_setAssociatedObject(self, ReconnectKey, @(1), OBJC_ASSOCIATION_COPY);
        
        if([self respondsToSelector:@selector(muteLocalAudioStream:)]) {
            [self performSelector:@selector(muteLocalAudioStream:) withObject:@(YES)];
        }
        if([self respondsToSelector:@selector(muteLocalVideoStream:)]) {
            [self performSelector:@selector(muteLocalVideoStream:) withObject:@(YES)];
        }
        
        if([self.delegate respondsToSelector:@selector(didReceivedConnectionStateChanged:)]) {
            [self.delegate didReceivedConnectionStateChanged:ConnectionStateReconnecting];
        }
        
    } else if(state == AgoraRtmConnectionStateDisconnected) {
        objc_setAssociatedObject(self, ReconnectKey, @(0), OBJC_ASSOCIATION_COPY);
        
        if([self respondsToSelector:@selector(muteLocalAudioStream:)]) {
            [self performSelector:@selector(muteLocalAudioStream:) withObject:@(YES)];
        }
        if([self respondsToSelector:@selector(muteLocalVideoStream:)]) {
            [self performSelector:@selector(muteLocalVideoStream:) withObject:@(YES)];
        }
        
        if([self.delegate respondsToSelector:@selector(didReceivedConnectionStateChanged:)]) {
            [self.delegate didReceivedConnectionStateChanged:ConnectionStateReconnected];
        }
        
    } else if(state == AgoraRtmConnectionStateAborted) {
        objc_setAssociatedObject(self, ReconnectKey, @(0), OBJC_ASSOCIATION_COPY);
        
        if([self.delegate respondsToSelector:@selector(didReceivedConnectionStateChanged:)]) {
            [self.delegate didReceivedConnectionStateChanged:ConnectionStateAnotherLogged];
        }
    }
}

#pragma mark Handle message
- (void)messageChat:(NSDictionary *)dict {
    
//    if([self.delegate respondsToSelector:@selector(didReceivedMessage:)]) {
//        MessageInfoModel *model = [MessageModel yy_modelWithDictionary:dict].data;
//
//        if(![model.userId isEqualToString:self.baseConfigModel.userId]) {
//            model.isSelfSend = NO;
//            [self.delegate didReceivedMessage:model];
//        }
//    }
}
- (void)messageUserInfo:(NSDictionary *)dict {
    
//    if([self.delegate respondsToSelector:@selector(didReceivedSignal:)]) {
//        NSArray<EduUserModel*> *userModels = [SignalUserModel yy_modelWithDictionary:dict].data;
//
//        SignalInfoModel *signalInfoModel = [SignalInfoModel new];
//
//        EduUserModel *originalHostModel = self.hostModel;
//        EduUserModel *originalOwnModel = self.ownModel;
//        NSMutableArray<EduUserModel *> *originalOwnModels = [NSMutableArray arrayWithArray:self.coUserModels];
//
//        EduUserModel *currentHostModel;
//        EduUserModel *currentOwnModel;
//        NSMutableArray<EduUserModel *> *currentOwnModels = [NSMutableArray array];
//        for(EduUserModel *userModel in userModels) {
//            if(userModel.role == UserRoleTypeTeacher) {
//                currentHostModel = userModel;
//            } else if(userModel.role == UserRoleTypeStudent) {
//                if(userModel.uid == originalOwnModel.uid) {
//                    currentOwnModel = userModel;
//                }
//                [currentOwnModels addObject:userModel];
//            }
//        }
//
//        // tea co
//        if ((originalHostModel == nil && currentHostModel != nil)
//            || (originalHostModel != nil && currentHostModel == nil)) {
//            self.hostModel = currentHostModel.yy_modelCopy;
//            originalHostModel = self.hostModel;
//
//            signalInfoModel.signalType = SignalValueCoVideo;
//            signalInfoModel.uid = originalHostModel.uid;
//            [self.delegate didReceivedSignal:signalInfoModel];
//        }
//        // tea mute & unmute
//        if (originalHostModel.enableAudio != currentHostModel.enableAudio) {
//            originalHostModel.enableAudio = currentHostModel.enableAudio;
//
//            signalInfoModel.signalType = SignalValueAudio;
//            signalInfoModel.uid = originalHostModel.uid;
//            [self.delegate didReceivedSignal:signalInfoModel];
//        }
//        if (originalHostModel.enableVideo != currentHostModel.enableVideo) {
//            originalHostModel.enableVideo = currentHostModel.enableVideo;
//
//            signalInfoModel.signalType = SignalValueVideo;
//            signalInfoModel.uid = originalHostModel.uid;
//            [self.delegate didReceivedSignal:signalInfoModel];
//        }
//
//        // board permission
//        if(originalOwnModel.grantBoard != currentOwnModel.grantBoard){
//            originalOwnModel.grantBoard = currentOwnModel.grantBoard;
//            for (EduUserModel *model in self.coUserModels){
//                if(model.uid == originalOwnModel.uid){
//                    model.grantBoard = currentOwnModel.grantBoard;
//                }
//            }
//
//            signalInfoModel.signalType = SignalValueGrantBoard;
//            signalInfoModel.uid = originalOwnModel.uid;
//            [self.delegate didReceivedSignal:signalInfoModel];
//        }
//
//        // chat & unchat
//        if (originalOwnModel.enableChat != currentOwnModel.enableChat) {
//            originalOwnModel.enableChat = currentOwnModel.enableChat;
//
//            signalInfoModel.signalType = SignalValueChat;
//            signalInfoModel.uid = originalOwnModel.uid;
//            [self.delegate didReceivedSignal:signalInfoModel];
//        }
//
//        // stu check
//        self.coUserModels = [currentOwnModels deepCopy];
//        self.ownModel = currentOwnModel.yy_modelCopy;
//        originalOwnModel = self.ownModel;
//        [self compareUserModelsFrom:originalOwnModels to:currentOwnModels];
//        [self compareUserModelsFrom:currentOwnModels to:originalOwnModels];
//
//        if (originalOwnModels.count != currentOwnModels.count ) {
//            signalInfoModel.signalType = SignalValueCoVideo;
//            [self.delegate didReceivedSignal:signalInfoModel];
//        } else {
//            // stu mute & unmute
//            for(EduUserModel *currentModel in currentOwnModels) {
//
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", currentModel.uid];
//                NSArray<EduUserModel *> *filteredArray = [originalOwnModels filteredArrayUsingPredicate:predicate];
//                if(filteredArray == 0) {
//                    signalInfoModel.signalType = SignalValueCoVideo;
//                    signalInfoModel.uid = currentModel.uid;
//                    [self.delegate didReceivedSignal:signalInfoModel];
//                } else {
//                    EduUserModel *filterUserModel = filteredArray.firstObject;
//                    if (filterUserModel.enableAudio != currentModel.enableAudio) {
//
//                        if(filterUserModel.uid == self.ownModel.uid) {
//                            if([self respondsToSelector:@selector(muteLocalAudioStream:)]) {
//                                [self performSelector:@selector(muteLocalAudioStream:) withObject:@(!currentModel.enableAudio)];
//                            }
//                        }
//
//                        filterUserModel.enableAudio = currentModel.enableAudio;
//
//                        signalInfoModel.signalType = SignalValueAudio;
//                        signalInfoModel.uid = filterUserModel.uid;
//                        [self.delegate didReceivedSignal:signalInfoModel];
//                    }
//                    if (filterUserModel.enableVideo != currentModel.enableVideo) {
//
//                        if(filterUserModel.uid == self.ownModel.uid) {
//                            if([self respondsToSelector:@selector(muteLocalVideoStream:)]) {
//                                [self performSelector:@selector(muteLocalVideoStream:) withObject:@(!currentModel.enableVideo)];
//                            }
//                        }
//
//                        filterUserModel.enableVideo = currentModel.enableVideo;
//
//                        signalInfoModel.signalType = SignalValueVideo;
//                        signalInfoModel.uid = filterUserModel.uid;
//                        [self.delegate didReceivedSignal:signalInfoModel];
//                    }
//                    [originalOwnModels removeObjectsInArray:filteredArray];
//                }
//            }
//        }
//    }
}
- (void)messageRoomInfo:(NSDictionary *)dict {
//    if([self.delegate respondsToSelector:@selector(didReceivedSignal:)]) {
//        
//        SignalRoomInfoModel *model = [SignalRoomModel yy_modelWithDictionary:dict].data;
//        
//        SignalInfoModel *signalInfoModel = [SignalInfoModel new];
//        
//        EduRoomModel *originalModel = self.roomModel;
//        if (originalModel.muteAllChat != model.muteAllChat) {
//            originalModel.muteAllChat = model.muteAllChat;
//            
//            signalInfoModel.signalType = SignalValueAllChat;
//            [self.delegate didReceivedSignal:signalInfoModel];
//        }
//        if (originalModel.lockBoard != model.lockBoard) {
//            originalModel.lockBoard = model.lockBoard;
//            
//            signalInfoModel.signalType = SignalValueFollow;
//            [self.delegate didReceivedSignal:signalInfoModel];
//        }
//        if (originalModel.courseState != model.courseState) {
//            originalModel.courseState = model.courseState;
//            originalModel.startTime = model.startTime;
//            
//            signalInfoModel.signalType = SignalValueCourse;
//            [self.delegate didReceivedSignal:signalInfoModel];
//        }
//    }
}
- (void)messageReplay:(NSDictionary *)dict {
//    if([self.delegate respondsToSelector:@selector(didReceivedMessage:)]) {
//        SignalReplayModel *model = [SignalReplayModel yy_modelWithDictionary:dict];
//
//        MessageInfoModel *messageModel = [MessageInfoModel new];
//        messageModel.userName = self.hostModel.userName;
//        messageModel.message = NSLocalizedString(@"ReplayRecordingText", nil);
//        messageModel.recordId = model.data.recordId;
//        messageModel.isSelfSend = NO;
//        [self.delegate didReceivedMessage:messageModel];
//    }
}
- (void)messageShareScreen:(NSDictionary *)dict {
//    if([self.delegate respondsToSelector:@selector(didReceivedSignal:)]) {
//        self.shareScreenInfoModel = [SignalShareScreenModel yy_modelWithDictionary:dict].data;
//
//        SignalInfoModel *signalInfoModel = [SignalInfoModel new];
//        signalInfoModel.signalType = SignalValueShareScreen;
//        [self.delegate didReceivedSignal:signalInfoModel];
//    }
}

#pragma mark Private
- (void)compareUserModelsFrom:(NSArray<EduUserModel *>*)fromArray to:(NSArray<EduUserModel *>*)toArray {
    
    SignalInfoModel *signalInfoModel = [SignalInfoModel new];
    
    NSPredicate *filterPredicate1 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", toArray];
    NSArray *filter1 = [fromArray filteredArrayUsingPredicate:filterPredicate1];
    
    for(EduUserModel *changedModel in filter1) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", changedModel.uid];
        NSArray<EduUserModel *> *filteredArray = [toArray filteredArrayUsingPredicate:predicate];
        if(filteredArray == 0) {
            // fromArray == originalOwnModels 下麦
            // fromArray == currentOwnModels 上麦
            signalInfoModel.signalType = SignalValueCoVideo;
            signalInfoModel.uid = changedModel.uid;
            [self.delegate didReceivedSignal:signalInfoModel];
        } else {
            EduUserModel *filterUserModel = filteredArray.firstObject;
            if (filterUserModel.enableAudio != changedModel.enableAudio) {
                filterUserModel.enableAudio = changedModel.enableAudio;
                
                signalInfoModel.signalType = SignalValueAudio;
                signalInfoModel.uid = filterUserModel.uid;
                [self.delegate didReceivedSignal:signalInfoModel];
            }
            if (filterUserModel.enableVideo != changedModel.enableVideo) {
                filterUserModel.enableVideo = changedModel.enableVideo;
                
                signalInfoModel.signalType = SignalValueVideo;
                signalInfoModel.uid = filterUserModel.uid;
                [self.delegate didReceivedSignal:signalInfoModel];
            }
        }
    }
}

@end
