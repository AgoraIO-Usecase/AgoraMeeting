//
//  ConferenceDelegate.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomEnum.h"

#import "ConfSignalP2PModel.h"
#import "ConfSignalChannelInOutModel.h"
#import "ConfSignalChannelRoomModel.h"
#import "ConfSignalChannelBoardModel.h"
#import "ConfSignalChannelScreenModel.h"
#import "ConfSignalChannelKickoutModel.h"
#import "MessageModel.h"

typedef NS_ENUM(NSInteger, ChannelMessageType) {
    ChannelMessageTypeChat              = 1,
    ChannelMessageTypeInOut             = 2,
    ChannelMessageTypeRoomInfo          = 3,
    ChannelMessageTypeUserInfo          = 4,
    ChannelMessageTypeShareBoard        = 5,
    ChannelMessageTypeShareScreen       = 6,
    ChannelMessageTypeHostChange        = 7,
    ChannelMessageTypeKickoff           = 8,
};

NS_ASSUME_NONNULL_BEGIN

@protocol ConferenceDelegate <NSObject>

@optional
- (void)didReceivedPeerSignal:(ConfSignalP2PInfoModel * _Nonnull)model;

- (void)didReceivedSignalInOut:(NSArray<ConfSignalChannelInOutInfoModel *> *)models;
- (void)didReceivedSignalRoomInfo:(ConfSignalChannelRoomModel *)model;
- (void)didReceivedSignalUserInfo:(ConfUserModel *)model;
- (void)didReceivedSignalShareBoard:(ConfSignalChannelBoardModel *)model;
- (void)didReceivedSignalShareScreen:(ConfSignalChannelScreenModel *)model;
- (void)didReceivedSignalHostChange:(NSArray<ConfUserModel*> *)hostModels;
- (void)didReceivedSignalKickoutChange:(ConfSignalChannelKickoutModel*)model;

- (void)didReceivedMessage:(MessageInfoModel * _Nonnull)model;
- (void)didReceivedConnectionStateChanged:(ConnectionState)state;

- (void)didAudioRouteChanged:(AudioOutputRouting)routing;
- (void)networkTypeGrade:(NetworkGrade)grade uid:(NSInteger)uid;

@end

NS_ASSUME_NONNULL_END
