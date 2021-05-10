//
//  LogManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/3/24.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "LogManager.h"
#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "URL.h"
#import "OSSManager.h"
#import <YYModel/YYModel.h>
#import <SSZipArchive/SSZipArchive.h>
#import "HttpManager+Public.h"
#import <AgoraLog/AgoraLogger.h>

typedef NS_ENUM(NSInteger, ZipStateType) {
    ZipStateTypeOK              = 0,
    ZipStateTypeOnNotFound      = 1,
    ZipStateTypeOnRemoveError   = 2,
    ZipStateTypeOnZipError      = 3,
};

@interface LogManager ()

@property (nonatomic, strong)AgoraLogger *logger;

@end


@implementation LogManager
+ (instancetype)sharedInstance {
    static LogManager * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[super allocWithZone:nil] init];
        NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/Logs"];
        ins.logger = [[AgoraLogger alloc] initWithFolderPath:logFilePath filePrefix:@"AgoraRoom" maximumNumberOfFiles:5];
        [ins.logger setPrintOnConsoleType:AgoraConsolePrintTypeAll];
    });
    return ins;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[self class] sharedInstance];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[self class] sharedInstance];
}

+ (void)debug:(NSString *)text {
    [[LogManager sharedInstance].logger log:text type:AgoraLogTypeDebug];
}

+ (void)info:(NSString *)text {
    [[LogManager sharedInstance].logger log:text type:AgoraLogTypeInfo];
}

+ (void)error:(NSString *)text {
    [[LogManager sharedInstance].logger log:text type:AgoraLogTypeError];
}

@end
