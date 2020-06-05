//
//  ConfConfigModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseConfigModel.h"
#import "EntryParams.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfConfigModel : BaseConfigModel

+ (instancetype)shareInstance;

// conference local data
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, assign) BOOL enableVideo;
@property (nonatomic, assign) BOOL enableAudio;
@property (nonatomic, copy) NSString *avatar;

@end

NS_ASSUME_NONNULL_END
