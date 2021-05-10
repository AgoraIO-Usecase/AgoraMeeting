//
//  ARConferenceEntryParams.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/7.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AREnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARConferenceEntryParams : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL videoAccess;
@property (nonatomic, assign) BOOL audioAccess;
@property (nonatomic, strong) NSString *avatar;

/// about app
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *customerCertificate;

/** 日志保存路径 **/
@property (nonatomic, copy) NSString *logFilePath;
/** 日志打印类型 **/
@property (nonatomic, assign) ARConsolePrintType logPrintType;


@end

NS_ASSUME_NONNULL_END
