//
//  AppUpdateManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/31.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppUpdateManager : NSObject

+ (instancetype)shareManager;
- (void)checkAppUpdate;

@end

NS_ASSUME_NONNULL_END
