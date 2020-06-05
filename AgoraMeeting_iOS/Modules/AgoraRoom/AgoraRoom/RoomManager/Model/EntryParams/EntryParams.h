//
//  EntryParams.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EduSceneType) {
    SceneType1V1        = 0,
    SceneTypeSmall      = 1,
    SceneTypeBig        = 2,
};

typedef NS_ENUM(NSInteger, UserRoleType) {
    UserRoleTypeTeacher = 1,
    UserRoleTypeStudent = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface EntryParams : NSObject

@end

NS_ASSUME_NONNULL_END
