//
//  HttpClient.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/11.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPSessionManager;


NS_ASSUME_NONNULL_BEGIN

@interface HttpClient : NSObject

@property(nonatomic, strong)AFHTTPSessionManager *sessionManager;

+ (instancetype)share;

@end

NS_ASSUME_NONNULL_END
