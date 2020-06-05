//
//  RTMManagerDelegate.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTMManagerDelegate <NSObject>

@optional

- (void)didReceivedSignal:(NSString *)signalText fromPeer: (NSString *)peer;
- (void)didReceivedSignal:(NSString *)signalText;
- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state;

@end

NS_ASSUME_NONNULL_END

