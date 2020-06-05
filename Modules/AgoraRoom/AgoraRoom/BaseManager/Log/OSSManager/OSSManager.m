//
//  OSSManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/3/30.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "OSSManager.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>
#import "URL.h"
#import "CommonModel.h"
#import <YYModel.h>

static OSSManager *manager = nil;

@interface OSSManager()
@property(nonatomic, strong)OSSClient *ossClient;
@property(nonatomic, strong)NSString *endpoint;
@property(nonatomic, assign)BOOL initOSSAuthClient;

@end

@implementation OSSManager

+ (instancetype)shareManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.initOSSAuthClient = NO;
    });
    return manager;
}

+ (void)initOSSAuthClientWithSTSURL:(NSString *)stsURL endpoint:(NSString*)endpoint {
    
    OSSAuthCredentialProvider *credentialProvider = [[OSSAuthCredentialProvider alloc] initWithAuthServerUrl:stsURL];
    OSSClientConfiguration *cfg = [[OSSClientConfiguration alloc] init];
    
    [OSSManager shareManager].ossClient = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credentialProvider clientConfiguration:cfg];
}

+ (void)uploadOSSWithSceneType:(SceneType)sceneType bucketName:(NSString *)bucketName objectKey:(NSString *)objectKey callbackBody:(NSString *)callbackBody callbackBodyType:(NSString *)callbackBodyType endpoint:(NSString*)endpoint fileURL:(NSURL *)fileURL completeSuccessBlock:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    if(!OSSManager.shareManager.initOSSAuthClient){
        OSSManager.shareManager.initOSSAuthClient = YES;
        NSString *stsURL = [NSString stringWithFormat:HTTP_OSS_STS, HTTP_BASE_URL];
        if(sceneType == SceneTypeConference){
            stsURL = [stsURL stringByReplacingOccurrencesOfString:HTTP_EDU_HOST_URL withString:HTTP_MEET_HOST_URL];
        }
        
        [OSSManager initOSSAuthClientWithSTSURL:stsURL endpoint:endpoint];
    }

    OSSPutObjectRequest * request = [OSSPutObjectRequest new];
    request.bucketName = bucketName;
    request.objectKey = objectKey;
    request.uploadingFileURL = fileURL;
    NSString *callbackURL = [NSString stringWithFormat:HTTP_OSS_STS_CALLBACK, HTTP_BASE_URL];
    if(sceneType == SceneTypeConference){
        callbackURL = [callbackURL stringByReplacingOccurrencesOfString:HTTP_EDU_HOST_URL withString:HTTP_MEET_HOST_URL];
    }
    request.callbackParam = @{
        @"callbackUrl": callbackURL,
        @"callbackBody": callbackBody,
        @"callbackBodyType": callbackBodyType};
    
    OSSTask *putTask = [[OSSManager shareManager].ossClient putObject:request];
    [putTask continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {

        if (!task.error) {

            OSSPutObjectResult *uploadResult = task.result;
            CommonModel *model = [CommonModel yy_modelWithJSON:uploadResult.serverReturnJsonString];
            if(model.code == 0){
                if(successBlock != nil) {
                    successBlock(model.data);
                }
            } else {
                if(failBlock != nil) {
                    NSError *error = LocalError(model.code, model.msg);
                    failBlock(error);
                }
            }

        } else {
            if(failBlock != nil) {
                failBlock(task.error);
            }
        }
        return nil;
    }];
}
@end
