//
//  HMError.m
//  AgoraRoom
//
//  Created by ZYP on 2021/1/26.
//  Copyright © 2021 agora. All rights reserved.
//

#import "HMError.h"

@implementation HMError

+ (instancetype)errorWithCodeType:(HMErrorCodeType)type
                          extCode:(NSInteger)extCode
                              msg:(NSString *)msg{
    NSString *message = [HMError getLocalErroMsg:extCode];
    message = message == nil ? msg : message;
    NSString *desc = [NSString stringWithFormat:@"%@", message];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: desc};
    return [[HMError alloc] initWithDomain:@"com.agora.meeting.hmerror" code:type userInfo:userInfo];
}

/// meeting server error code
+ (NSString *)getLocalErroMsg:(NSInteger)code {
    
    switch (code) {
        case 32403100:
            return NSLocalizedString(@"http_t1", @"");
        case 32409200:
            return NSLocalizedString(@"http_t2", @"");
        case 32409201:
            return NSLocalizedString(@"http_t3", @"");
        case 32409202:
            return NSLocalizedString(@"http_t4", @"");
        case 32409203:
            return NSLocalizedString(@"http_t5", @"");
        case 32410200:
            return NSLocalizedString(@"http_t6", @"");
        case 32410201:
            return NSLocalizedString(@"http_t7", @"");
        case 32400000:
            return NSLocalizedString(@"http_t8", @"");
        case 32400001:
            return NSLocalizedString(@"http_t9", @"");
        case 32400002:
            return NSLocalizedString(@"http_t10", @"");
        case 32400003:
            return NSLocalizedString(@"http_t11", @"");
        case 32400004:
            return NSLocalizedString(@"http_t12", @"");
        case 32400005:
            return NSLocalizedString(@"http_t13", @"");
        case 32403300:
            return NSLocalizedString(@"http_t14", @"");
        case 32403420:
            return NSLocalizedString(@"http_t15", @"");
        case 32404300:
            return NSLocalizedString(@"http_t16", @"");
        case 32404420:
            return NSLocalizedString(@"http_t17", @"");
        case 32409300:
            return NSLocalizedString(@"http_t18", @"");
        case 32409420:
            return NSLocalizedString(@"http_t19", @"");
        case 30404420:
            return NSLocalizedString(@"http_t20", @"");
        case 20403002:
            return NSLocalizedString(@"http_t22", @"");
        case 20403001:
            return NSLocalizedString(@"http_t23", @"");

        case -1009:
            return NSLocalizedString(@"http_t21", @"");
        default:
            return nil;
    }
}


@end
