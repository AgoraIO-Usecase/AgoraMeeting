//
//  ConferenceEntryParams.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EntryParams.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConferenceEntryParams : EntryParams

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL enableVideo;
@property (nonatomic, assign) BOOL enableAudio;
@property (nonatomic, strong) NSString *avatar;

@end

NS_ASSUME_NONNULL_END
