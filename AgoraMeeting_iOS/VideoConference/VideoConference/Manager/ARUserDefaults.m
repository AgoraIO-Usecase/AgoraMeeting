//
//  UserDefaults.m
//  VideoConference
//
//  Created by SRS on 2020/5/11.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ARUserDefaults.h"

#define DefaultStandardUser [NSUserDefaults standardUserDefaults]

@implementation ARUserDefaults

+ (NSString *)getUserName {
    NSString *name = [DefaultStandardUser objectForKey:@"UserName"];
    return name == nil ? @"" : name;
}
+ (void)setUserName:(NSString *)userName {
    [DefaultStandardUser setObject:userName forKey:@"UserName"];
    [DefaultStandardUser synchronize];
}

+ (NSString *)getRoomName {
    NSString *name = [DefaultStandardUser objectForKey:@"RoomName"];
    return name == nil ? @"" : name;
}
+ (void)setRoomName:(NSString *)roomName {
    [DefaultStandardUser setObject:roomName forKey:@"RoomName"];
    [DefaultStandardUser synchronize];
}

+ (BOOL)getOpenCamera {
    NSNumber *value = [DefaultStandardUser objectForKey:@"OpenCamera"];
    return value == nil ? YES : value.boolValue;
}
+ (void)setOpenCamera:(BOOL)openCamera {
    [DefaultStandardUser setObject:@(openCamera) forKey:@"OpenCamera"];
    [DefaultStandardUser synchronize];
}

+ (BOOL)getOpenMic {
    NSNumber *value = [DefaultStandardUser objectForKey:@"OpenMic"];
    return value == nil ? YES : value.boolValue;
}
+ (void)setOpenMic:(BOOL)openMic {
    [DefaultStandardUser setObject:@(openMic) forKey:@"OpenMic"];
    [DefaultStandardUser synchronize];
}

+ (void)setNotiTypeValue:(NSInteger)value {
    [DefaultStandardUser setValue:@(value) forKey:@"NotiTypeValue"];
    [DefaultStandardUser synchronize];
}

+ (NSInteger)getNotiTypeValue {
    NSNumber *value = [DefaultStandardUser valueForKey:@"NotiTypeValue"];
    if(value == nil) {
        value = @5;
        [ARUserDefaults setNotiTypeValue:5];
    }
    return value.intValue;
}


+ (nonnull NSString *)getCurrentUUID {
    NSString *uuid = [DefaultStandardUser objectForKey:@"uuid"];
    if (uuid == nil) {
        uuid = [NSUUID UUID].UUIDString;
        [DefaultStandardUser setObject:uuid forKey:@"uuid"];
        [DefaultStandardUser synchronize];
    }
    return uuid;
}


@end
