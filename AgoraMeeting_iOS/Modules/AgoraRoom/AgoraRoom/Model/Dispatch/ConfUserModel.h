//
//  EduUserModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/23.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfUserModel : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) NSInteger role;
@property (nonatomic, assign) NSInteger enableChat;
@property (nonatomic, assign) NSInteger enableVideo;
@property (nonatomic, assign) NSInteger enableAudio;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger screenId;
@property (nonatomic, assign) NSInteger grantBoard;
@property (nonatomic, assign) NSInteger grantScreen;
@property (nonatomic, assign) NSInteger state;

@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *rtcToken;
@property (nonatomic, strong) NSString *rtmToken;
@property (nonatomic, strong) NSString *screenToken;

- (BOOL)isEqualToModel:(ConfUserModel *)model;

@end

NS_ASSUME_NONNULL_END
