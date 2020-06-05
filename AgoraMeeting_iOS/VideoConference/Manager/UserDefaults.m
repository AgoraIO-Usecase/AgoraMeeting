//
//  UserDefaults.m
//  VideoConference
//
//  Created by SRS on 2020/5/11.
//  Copyright © 2020 agora. All rights reserved.
//

#import "UserDefaults.h"

#define DefaultStandardUser [NSUserDefaults standardUserDefaults]

@implementation UserDefaults

+ (NSString *)getUserName {
    NSString *name = [DefaultStandardUser objectForKey:@"UserName"];
    return name == nil ? @"" : name;
}
+ (void)setUserName:(NSString *)userName {
    [DefaultStandardUser setObject:userName forKey:@"UserName"];
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

@end
