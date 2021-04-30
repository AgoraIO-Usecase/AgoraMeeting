//
//  VideoCellModel.h
//  VideoConference
//
//  Created by ZYP on 2020/12/28.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCellModel : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) NSInteger role;
@property (nonatomic, assign) BOOL enableVideo;
@property (nonatomic, assign) BOOL enableAudio;
@property (nonatomic, assign) BOOL shareBoard;
@property (nonatomic, assign) BOOL shareScreen;
@property (nonatomic, assign) BOOL isMe;
@property (nonatomic, assign) BOOL localUserIsHost;
@property (nonatomic, strong) NSString *headImageName;

- (BOOL)isEqualToModel:(VideoCellModel *)model;

@end

NS_ASSUME_NONNULL_END
