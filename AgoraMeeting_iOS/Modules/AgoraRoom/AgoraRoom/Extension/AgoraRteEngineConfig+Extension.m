//
//  AgoraRteEngineConfig+Extension.m
//  AgoraRoom
//
//  Created by ZYP on 2021/1/7.
//  Copyright © 2021 agora. All rights reserved.
//

#import "AgoraRteEngineConfig+Extension.h"
#import "ARConferenceEntryParams.h"

@implementation AgoraRteEngineConfig (Extension)

+ (AgoraRteEngineConfig *)instanceWithEntryparams:(ARConferenceEntryParams *)params {
    NSString *appId = params.appId;
    NSString *customerId = params.customerId;
    NSString *customerCertificate = params.customerCertificate;
    NSString *userId = params.userUuid;
    NSString *logFilePath = params.logFilePath;
    
    AgoraConsolePrintType logConsolePrintType = AgoraConsolePrintTypeNone;
    switch (params.logPrintType) {
        case ARConsolePrintTypeNone:
            logConsolePrintType = AgoraConsolePrintTypeNone;
        case ARConsolePrintTypeDebug:
            logConsolePrintType = AgoraConsolePrintTypeDebug;
        case ARConsolePrintTypeInfo:
            logConsolePrintType = AgoraConsolePrintTypeInfo;
        case ARConsolePrintTypeError:
            logConsolePrintType = AgoraConsolePrintTypeError;
        case ARConsolePrintTypeWarning:
            logConsolePrintType = AgoraConsolePrintTypeWarning;
        case ARConsolePrintTypeAll:
            logConsolePrintType = AgoraConsolePrintTypeAll;
        default:
            logConsolePrintType = AgoraConsolePrintTypeNone;
    }
    AgoraRteEngineConfig *config = [[AgoraRteEngineConfig alloc] initWithAppId:appId
                                                                    customerId:customerId
                                                           customerCertificate:customerCertificate
                                                                        userId:userId];
    config.logFilePath = logFilePath;
    config.logConsolePrintType = logConsolePrintType;
    return config;
}


@end
