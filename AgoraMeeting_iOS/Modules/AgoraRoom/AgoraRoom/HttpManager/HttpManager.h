//
//  HttpManager.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/11.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HMSuccessBlock)(id _Nullable);
typedef void (^HMFailBlock)(NSError *_Nonnull);

@class HMHttpHeader1, AFHTTPSessionManager, HMRespone;

NS_ASSUME_NONNULL_BEGIN

@interface HttpManager : NSObject

+ (void)get:(NSString *)url
     params:(NSDictionary * _Nullable) params
    headers:(NSDictionary<NSString*, NSString*> * _Nullable)headers
    success:(HMSuccessBlock _Nullable)success
    failure:(HMFailBlock _Nullable)failure;

+ (void)post:(NSString *)url
      params:(NSDictionary * _Nullable)params
     headers:(NSDictionary<NSString*, NSString*> * _Nullable)headers
     success:(HMSuccessBlock _Nullable)success
     failure:(HMFailBlock _Nullable)failure;

+ (void)put:(NSString *)url
     params:(NSDictionary * _Nullable)params
    headers:(NSDictionary<NSString*, NSString*> * _Nullable)headers
    success:(HMSuccessBlock _Nullable)success
    failure:(HMFailBlock _Nullable)failure;

+ (BOOL)checkResp:(HMRespone * _Nonnull)resp failure:(HMFailBlock _Nullable)failure;
+ (NSError *)rebaseSystemError:(NSError *)error;
+ (void)setCustomerId:(NSString *)customerId
          customerCer:(NSString *)customerCer;

@end

NS_ASSUME_NONNULL_END
