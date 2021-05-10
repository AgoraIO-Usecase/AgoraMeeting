//
//  HttpManager.m
//  AgoraRoom
//
//  Created by ZYP on 2021/1/11.
//  Copyright © 2021 agora. All rights reserved.
//

#import "HttpManager.h"
#import "AFNetworking.h"
#import "URL.h"
#import "HttpClient.h"
#import "LogManager.h"
#import "HMRespone.h"
#import "HMError.h"

static HMHttpHeader1 *httpHeader1;
static NSString *authorization;

@implementation HttpManager

+ (void)get:(NSString *)url
     params:(NSDictionary * _Nullable) params
    headers:(NSDictionary<NSString*, NSString*> * _Nullable)headers
    success:(HMSuccessBlock _Nullable)success
    failure:(HMFailBlock _Nullable)failure {
    [self logWithUrl:url headers:headers params:params];
    
    
    NSMutableDictionary *h = [NSMutableDictionary new];
    h[@"Authorization"] = authorization;
    
    NSArray<NSString*> *keys = headers.allKeys;
    for(NSString *key in keys){
        [HttpClient.share.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
    }
    
    [HttpClient.share.sessionManager GET:url parameters:params headers:h progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self logWithUrl:url response:responseObject];
        if(success) { success(responseObject); }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logWithUrl:url error:error];
        NSError *e = [HttpManager rebaseSystemError:error];
        if(failure) { failure(e); }
    }];
}


+ (void)post:(NSString *)url
      params:(NSDictionary * _Nullable)params
     headers:(NSDictionary<NSString*, NSString*> * _Nullable)headers
     success:(HMSuccessBlock _Nullable)success
     failure:(HMFailBlock _Nullable)failure {
    [self logWithUrl:url headers:headers params:params];
    NSMutableDictionary *h = [NSMutableDictionary new];
    h[@"Authorization"] = authorization;
    
    NSArray<NSString*> *keys = headers.allKeys;
    for(NSString *key in keys){
        [HttpClient.share.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
    }
    
    [HttpClient.share.sessionManager POST:url parameters:params headers:h progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self logWithUrl:url response:responseObject];
        if(success) { success(responseObject); }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logWithUrl:url error:error];
        NSError *e = [HttpManager rebaseSystemError:error];
        if(failure) { failure(e); }
    }];
}

+ (void)put:(NSString *)url
     params:(NSDictionary * _Nullable)params
    headers:(NSDictionary<NSString*, NSString*> * _Nullable)headers
    success:(HMSuccessBlock _Nullable)success
    failure:(HMFailBlock _Nullable)failure {
    NSMutableDictionary *h = [NSMutableDictionary new];
    h[@"Authorization"] = authorization;
    
    NSArray<NSString*> *keys = headers.allKeys;
    for(NSString *key in keys){
        [HttpClient.share.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
    }
    [self logWithUrl:url headers:headers params:params];
    [HttpClient.share.sessionManager PUT:url parameters:params headers:h success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self logWithUrl:url response:responseObject];
        if(success) { success(responseObject); }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logWithUrl:url error:error];
        NSError *e = [HttpManager rebaseSystemError:error];
        if(failure) { failure(e); }
    }];
}



+ (void)logWithUrl:(NSString *)url
           headers:(NSDictionary<NSString*, NSString*> * _Nullable)headers
            params:(NSDictionary * _Nullable) params  {
    NSString *str = [NSString stringWithFormat:@"\n============>Get HTTP Start<============\n\
                     \nurl==>\n%@\n\
                     \nheaders==>\n%@\n\
                     \nparams==>\n%@\n\
                     ", url, headers, params];
    [LogManager info:str];
}

+ (void)logWithUrl:(NSString *)url
          response:(id)responseObject {
    NSString *str = [NSString stringWithFormat:@"\n============>Get HTTP Success<============\n\
                     \nurl==>\n%@\n\
                     \nResult==>\n%@\n\
                     ", url, responseObject];
    [LogManager info:str];
}

+ (void)logWithUrl:(NSString *)url
             error:(NSError *)error {
    NSString *str = [NSString stringWithFormat:@"\n============>Get HTTP Error<============\n\
                     \nurl==>\n%@\n\
                     \nError==>\n%@\n\
                     ", url, error.description];
    [LogManager info:str];
}

/// 检查返回是否合法
+ (BOOL)checkResp:(HMRespone * _Nonnull)resp failure:(HMFailBlock _Nullable)failure {
    if(resp.code != 0) {
        HMError *e = [HMError errorWithCodeType:HMErrorCodeTypeReqFaild extCode:resp.code msg:resp.msg];
        if(failure) { failure(e); }
        return false;
    }
    return true;
}


+ (NSError *)rebaseSystemError:(NSError *)error {
    if (error != nil && error.code == -1009) {
        return [HMError errorWithCodeType:HMErrorCodeTypeNetWorkFail extCode:error.code msg:@""];
    }
    return error;
}

+ (void)setCustomerId:(NSString *)customerId
          customerCer:(NSString *)customerCer {
    NSString *target = [NSString stringWithFormat:@"%@:%@", customerId, customerCer];
    NSData *data = [target dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    
    authorization = [NSString stringWithFormat:@"Basic %@", base64Str];
}

@end
