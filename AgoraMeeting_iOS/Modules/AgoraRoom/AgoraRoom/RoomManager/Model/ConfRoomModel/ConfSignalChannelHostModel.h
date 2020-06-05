//
//  ConfSignalChannelHostModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfSignalChannelHostModel : NSObject

@property (nonatomic, strong) NSArray<ConfUserModel*> *data;

@end

NS_ASSUME_NONNULL_END
