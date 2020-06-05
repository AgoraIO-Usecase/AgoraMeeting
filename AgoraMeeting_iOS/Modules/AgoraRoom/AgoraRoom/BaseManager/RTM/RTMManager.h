//
//  RTMManager.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtmKit/AgoraRtmKit.h>
#import "RTMManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTMManager : NSObject

- (void)initSignalWithAppid:(NSString *)appId appToken:(NSString *)appToken userId:(NSString *)uid dataSourceDelegate:(id<RTMManagerDelegate> _Nullable)rtmDelegate completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock;

- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock;

- (void)sendMessage:(NSString *)value completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (NSInteger errorCode))failBlock;
    
- (void)releaseSignalResources;

@end

NS_ASSUME_NONNULL_END
