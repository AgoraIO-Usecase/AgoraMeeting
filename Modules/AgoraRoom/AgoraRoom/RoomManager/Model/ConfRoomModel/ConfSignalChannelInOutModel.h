//
//  ConfSignalChannelInOutModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfSignalChannelInOutInfoModel : ConfUserModel


@end

@interface ConfSignalChannelInOutModel : NSObject

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray<ConfSignalChannelInOutInfoModel*> *list;

@end

NS_ASSUME_NONNULL_END
