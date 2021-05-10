//
//  ARError.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/7.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AgoraRteError;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const RTEErrorDomain;
FOUNDATION_EXPORT NSErrorDomain const ARRteErrorDomain;

@interface ARError : NSError

+ (instancetype)errorWithRteError:(AgoraRteError *)error;

@end

NS_ASSUME_NONNULL_END
