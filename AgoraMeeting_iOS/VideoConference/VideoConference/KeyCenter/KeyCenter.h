//
//  KeyCenter.h
//  AgoraEducation
//
//  Created by ZYP on 2020/3/26.
//  Copyright © 2020 ZYP. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyCenter : NSObject
+ (NSString *)agoraAppid;

+ (NSString *)customerId;

+ (NSString *)customerCertificate;
@end

NS_ASSUME_NONNULL_END
