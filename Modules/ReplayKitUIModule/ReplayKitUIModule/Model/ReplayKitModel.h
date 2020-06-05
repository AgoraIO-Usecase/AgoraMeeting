//
//  ReplayKitModel.h
//  ReplayKitModule
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReplayKitModel : NSObject

@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;

@property (strong, nonatomic) NSString *boardId;
@property (strong, nonatomic) NSString *boardToken;

@end

NS_ASSUME_NONNULL_END
