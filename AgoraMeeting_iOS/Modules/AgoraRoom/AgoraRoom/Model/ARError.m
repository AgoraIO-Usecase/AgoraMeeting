//
//  ARError.m
//  AgoraRoom
//
//  Created by ZYP on 2021/1/7.
//  Copyright © 2021 agora. All rights reserved.
//

#import "ARError.h"
#import <AgoraRte/AgoraRteObjects.h>

NSString * const ARErrorDomain = @"com.agora.ar";
NSString * const ARRteErrorDomain = @"com.agora.ar.rte";

@interface ARError ()

@property (nonatomic, strong)AgoraRteError *rteError;

@end

@implementation ARError

+ (instancetype)errorWithRteError:(AgoraRteError *)error {
    return  [ARError errorWithDomain:ARRteErrorDomain code:error.code userInfo:nil];
}

- (NSString *)localizedDescription {
    return _rteError.message;
}

@end
