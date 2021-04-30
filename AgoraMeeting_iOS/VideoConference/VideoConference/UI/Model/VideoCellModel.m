//
//  VideoCellModel.m
//  VideoConference
//
//  Created by ZYP on 2020/12/28.
//  Copyright © 2020 agora. All rights reserved.
//

#import "VideoCellModel.h"

@implementation VideoCellModel

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }

  if (![object isKindOfClass:[VideoCellModel class]]) {
    return NO;
  }

  return [self isEqualToModel:(VideoCellModel *)object];
}

- (BOOL)isEqualToModel:(VideoCellModel *)model {
    if (!model) {
        return NO;
    }

    BOOL equalUserId = (!self.userId && !model.userId) || [self.userId isEqualToString:model.userId];
    BOOL equalUserName = (!self.userName && !model.userName) || [self.userName isEqualToString:model.userName];
    BOOL equalRole = self.role == model.role;
    BOOL equalEnableVideo = self.enableVideo == model.enableVideo;
    BOOL equalEnableAudio = self.enableAudio == model.enableAudio;


  return equalUserId
    && equalUserName
    && equalRole
    && equalEnableVideo
    && equalEnableAudio;
    
}

- (NSUInteger)hash {
  return [self.userId hash]
    ^ [self.userName hash]
    ^ [@(self.role) hash]
    ^ [@(self.enableVideo) hash]
    ^ [@(self.enableAudio) hash];
}

@end
