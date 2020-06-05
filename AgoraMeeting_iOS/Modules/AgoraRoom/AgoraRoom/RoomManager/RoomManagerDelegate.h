//
//  RoomManagerDelegate.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalP2PModel.h"
#import "SignalInfoModel.h"
#import "MessageModel.h"
#import "RoomEnum.h"


NS_ASSUME_NONNULL_BEGIN

@protocol RoomManagerDelegate <NSObject>

@optional

- (void)didReceivedSignal:(NSString *)signalText fromPeer:(NSString *)peer;
- (void)didReceivedSignal:(NSString *)signalText;

- (void)didAudioRouteChanged:(AudioOutputRouting)routing;
- (void)didReceivedConnectionStateChanged:(ConnectionState)state;

- (void)networkLastmileTypeGrade:(NetworkGrade)grade;
- (void)networkTypeGrade:(NetworkGrade)grade uid:(NSInteger)uid;

@end

NS_ASSUME_NONNULL_END
