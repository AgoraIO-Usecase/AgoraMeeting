//
//  ConfUserListInfoModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ConfUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfUserListInfoModel : NSObject

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSString *nextId;
@property (nonatomic, strong) NSArray<ConfUserModel *> *list;

@end

NS_ASSUME_NONNULL_END
