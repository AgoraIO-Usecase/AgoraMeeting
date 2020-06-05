//
//  UserDefaults.h
//  VideoConference
//
//  Created by SRS on 2020/5/11.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserDefaults : NSObject

+ (NSString *)getUserName;
+ (void)setUserName:(NSString *)userName;

+ (BOOL)getOpenCamera;
+ (void)setOpenCamera:(BOOL)openCamera;

+ (BOOL)getOpenMic;
+ (void)setOpenMic:(BOOL)openMic;

@end

NS_ASSUME_NONNULL_END
