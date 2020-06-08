//
//  HttpClient.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import "HttpClient.h"
#import <AFNetworking/AFNetworking.h>
#import "LogManager.h"

#define USER_TOKEN_EXPIRED_CODE 401

@interface HttpClient ()

@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@end

static HttpClient *manager = nil;

@implementation HttpClient
+ (instancetype)shareManager{
    @synchronized(self){
        if (!manager) {
            manager = [[self alloc]init];
            [manager initSessionManager];
        }
        return manager;
    }
}

- (void)initSessionManager {
    self.sessionManager = [AFHTTPSessionManager manager];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = 30;
}

+ (void)get:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    if(headers != nil && headers.allKeys.count > 0){
        NSArray<NSString*> *keys = headers.allKeys;
        for(NSString *key in keys){
            [HttpClient.shareManager.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    AgoraLogInfo(@"\n============>Get HTTP Start<============\n\
          \nurl==>\n%@\n\
          \nheaders==>\n%@\n\
          \nparams==>\n%@\n\
          ", url, headers, params);
    [HttpClient.shareManager.sessionManager GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        AgoraLogInfo(@"\n============>Get HTTP Success<============\n\
              \nurl==>\n%@\n\
              \nResult==>\n%@\n\
              ", url, responseObject);
        
        if ([HttpClient checkUserTokenExpired:responseObject]) {
            return;
        }
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AgoraLogInfo(@"\n============>Get HTTP Error<============\n\
              \nurl==>\n%@\n\
              \nError==>\n%@\n\
              ", url, error.description);
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure {

    if(headers != nil && headers.allKeys.count > 0){
        NSArray<NSString*> *keys = headers.allKeys;
        for(NSString *key in keys){
            [HttpClient.shareManager.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }

    AgoraLogInfo(@"\n============>Post HTTP Start<============\n\
          \nurl==>\n%@\n\
          \nheaders==>\n%@\n\
          \nparams==>\n%@\n\
          ", url, headers, params);
    
    [HttpClient.shareManager.sessionManager POST:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        AgoraLogInfo(@"\n============>Post HTTP Success<============\n\
              \nurl==>\n%@\n\
              \nResult==>\n%@\n\
              ", url, responseObject);
        
        if ([HttpClient checkUserTokenExpired:responseObject]) {
            return;
        }
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        AgoraLogInfo(@"\n============>Get HTTP Error<============\n\
              \nurl==>\n%@\n\
              \nError==>\n%@\n\
              ", url, error.description);
        if (failure) {
          failure(error);
        }
    }];
}

+ (BOOL)checkUserTokenExpired:(id)responseObject {
    
    if (responseObject && [responseObject[@"code"] integerValue] == USER_TOKEN_EXPIRED_CODE) {
        
        AgoraLogInfo(@"user token expired");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_USER_TOKEN_EXPIRED object:nil];
        return YES;
    }
    return NO;
}

@end
