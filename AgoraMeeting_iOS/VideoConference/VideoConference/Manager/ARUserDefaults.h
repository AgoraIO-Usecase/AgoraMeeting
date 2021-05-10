//
//  UserDefaults.h
//  VideoConference
//
//  Created by SRS on 2020/5/11.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARUserDefaults : NSObject

+ (NSString *)getUserName;
+ (void)setUserName:(NSString *)userName;

+ (NSString *)getRoomName;
+ (void)setRoomName:(NSString *)roomName;

+ (BOOL)getOpenCamera;
+ (void)setOpenCamera:(BOOL)openCamera;

+ (BOOL)getOpenMic;
+ (void)setOpenMic:(BOOL)openMic;

+ (void)setNotiTypeValue:(NSInteger)value;
+ (NSInteger)getNotiTypeValue;

+ (nonnull NSString *)getCurrentUUID;

@end

NS_ASSUME_NONNULL_END
