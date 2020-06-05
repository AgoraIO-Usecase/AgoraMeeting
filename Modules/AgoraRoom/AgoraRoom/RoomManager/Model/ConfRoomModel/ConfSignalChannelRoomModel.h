//
//  ConfSignalChannelRoomModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfRoomModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ConfSignalChannelRoomModel : NSObject

@property (nonatomic, assign) MuteAllAudioState muteAllAudio;
@property (nonatomic, assign) BOOL state;// 1=正常 2=会议结束

@end

NS_ASSUME_NONNULL_END
