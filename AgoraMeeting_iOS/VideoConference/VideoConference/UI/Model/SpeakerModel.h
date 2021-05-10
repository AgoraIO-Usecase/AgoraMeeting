//
//  SpeakerModel.h
//  VideoConference
//
//  Created by ZYP on 2021/2/23.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SpeakerModelType) {
    SpeakerModelTypeVideo = 0,
    SpeakerModelTypeScreen = 1,
    SpeakerModelTypeBoard = 2,
};

@interface SpeakerModel : NSObject

@property (nonatomic, strong)NSString *name;
@property (nonatomic, assign)BOOL hasAudio;
@property (nonatomic, assign)SpeakerModelType type;
@property (nonatomic, assign)BOOL isLocalUser;
@property (nonatomic, assign)BOOL isHost;

@end

NS_ASSUME_NONNULL_END
