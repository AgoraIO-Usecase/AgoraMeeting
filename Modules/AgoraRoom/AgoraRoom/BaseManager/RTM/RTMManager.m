//
//  RTMManager.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/5.
//  Copyright © 2020 agora. All rights reserved.
//

#import "RTMManager.h"
#import "LogManager.h"
#import "JsonParseUtil.h"

@interface RTMManager()<AgoraRtmDelegate, AgoraRtmChannelDelegate>

@property (nonatomic, weak) id<RTMManagerDelegate> delegate;
@property (nonatomic, strong) AgoraRtmKit *agoraRtmKit;
@property (nonatomic, strong) AgoraRtmChannel *agoraRtmChannel;

@property (nonatomic, strong) NSString * _Nullable channelName;
@property (nonatomic, strong) NSString * _Nullable uid;

@end

@implementation RTMManager
- (void)initSignalWithAppid:(NSString *)appId appToken:(NSString *)appToken userId:(NSString *)uid dataSourceDelegate:(id<RTMManagerDelegate> _Nullable)rtmDelegate completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    AgoraLogInfo(@"init signal appid:%@ apptoken:%@ uid:%@", appId, appToken, uid);
    
    self.uid = uid;
    self.delegate = rtmDelegate;
    
    self.agoraRtmKit = [[AgoraRtmKit alloc] initWithAppId:appId delegate:self];
    NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/Agora/agoraRTM.log"];
    [self.agoraRtmKit setLogFile:logFilePath];
    [self.agoraRtmKit setLogFileSize:512];
    [self.agoraRtmKit setLogFilters:AgoraRtmLogFilterInfo];
    [self.agoraRtmKit loginByToken:appToken user:uid completion:^(AgoraRtmLoginErrorCode errorCode) {
        if (errorCode == AgoraRtmLoginErrorOk) {
            AgoraLogInfo(@"rtm login success");
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                failBlock(errorCode);
            }
        }
    }];
}

- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    AgoraLogInfo(@"join signal channelName:%@", channelName);
    
    self.channelName = channelName;
    
    self.agoraRtmChannel = [self.agoraRtmKit createChannelWithId:channelName delegate:self];
    [self.agoraRtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
        
        if(errorCode == AgoraRtmJoinChannelErrorOk || errorCode == AgoraRtmJoinChannelErrorAlreadyJoined){
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                failBlock(errorCode);
            }
        }
    }];
}

- (void)sendMessage:(NSString *)value completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (NSInteger errorCode))failBlock {
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:value];
    [self.agoraRtmChannel sendMessage:rtmMessage completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
            
            if(successBlock != nil){
                successBlock();
            }
            
        } else {
            if(failBlock != nil){
                failBlock(errorCode);
            }
        }
    }];
}

- (void)releaseSignalResources {
    AgoraLogInfo(@"releaseSignalResources");
    
    if(self.channelName != nil){
        AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
        options.enableNotificationToChannelMembers = YES;
        [self.agoraRtmKit deleteChannel:self.channelName AttributesByKeys:@[self.uid] Options:options completion:nil];
        
        [self.agoraRtmChannel leaveWithCompletion:nil];
        self.channelName = nil;
    }
    
    [self.agoraRtmKit logoutWithCompletion:nil];
}

#pragma mark SignalManagerDelegate
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    
    AgoraLogInfo(@"connectionStateChanged state:%ld reason:%ld", (long)state, (long)reason);
    
    if([self.delegate respondsToSelector:@selector(didReceivedConnectionStateChanged:)]) {
        [self.delegate didReceivedConnectionStateChanged:state];
    }
}

- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    
    AgoraLogInfo(@"messageReceived:%@ fromPeer:%@", message.text, peerId);
    
    if([self.delegate respondsToSelector:@selector(didReceivedSignal:fromPeer:)]) {
        [self.delegate didReceivedSignal:message.text fromPeer:peerId];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {

    AgoraLogInfo(@"messageReceived:%@", message.text);
    if([self.delegate respondsToSelector:@selector(didReceivedSignal:)]) {
        [self.delegate didReceivedSignal:message.text];
    }
}
@end
