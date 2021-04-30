//
//  HttpClient.m
//  AgoraRoom
//
//  Created by ZYP on 2021/1/11.
//  Copyright © 2021 agora. All rights reserved.
//

#import "HttpClient.h"
#import <AFNetworking/AFNetworking.h>



@implementation HttpClient

+ (instancetype)share {
    static HttpClient *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HttpClient new];
        manager.sessionManager = [AFHTTPSessionManager manager];
        manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.sessionManager.requestSerializer.timeoutInterval = 30;
    });
    return manager;
}





@end
