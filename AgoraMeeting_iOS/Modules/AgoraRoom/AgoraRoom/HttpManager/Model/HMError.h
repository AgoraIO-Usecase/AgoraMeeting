//
//  HMError.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/26.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HMErrorCodeType) {
    /// 请求服务器失败
    HMErrorCodeTypeReqFaild = 1001,
    /// 网络异常
    HMErrorCodeTypeNetWorkFail = 1002,
};

NS_ASSUME_NONNULL_BEGIN

@interface HMError : NSError

/// code 类型
@property(nonatomic, assign)HMErrorCodeType type;

+ (instancetype)errorWithCodeType:(HMErrorCodeType)type extCode:(NSInteger)extCode msg:(NSString *)msg;
- (instancetype)initWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict NS_UNAVAILABLE;
+ (instancetype)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
