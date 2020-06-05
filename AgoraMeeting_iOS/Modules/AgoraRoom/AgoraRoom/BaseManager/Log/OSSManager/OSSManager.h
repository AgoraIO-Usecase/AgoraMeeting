//
//  OSSManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/3/30.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSManager : NSObject

+ (void)initOSSAuthClientWithSTSURL:(NSString *)stsURL endpoint:(NSString*)endpoint;

+ (void)uploadOSSWithSceneType:(SceneType)sceneType bucketName:(NSString *)bucketName objectKey:(NSString *)objectKey callbackBody:(NSString *)callbackBody callbackBodyType:(NSString *)callbackBodyType endpoint:(NSString*)endpoint fileURL:(NSURL *)fileURL completeSuccessBlock:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

@end

NS_ASSUME_NONNULL_END
