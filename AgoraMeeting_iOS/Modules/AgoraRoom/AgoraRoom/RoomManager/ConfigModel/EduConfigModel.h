//
//  EduConfigModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseConfigModel.h"
#import "EntryParams.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduConfigModel : BaseConfigModel

+ (instancetype)shareInstance;

// edu demo local data
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* roomName;
@property (nonatomic, assign) EduSceneType sceneType;

// edu saas local data
//@property (nonatomic, strong) NSString* userName;
//@property (nonatomic, assign) EduSceneType sceneType;
@property (nonatomic, copy) NSString* password;

@end

NS_ASSUME_NONNULL_END
