//
//  ConfSignalChannelScreenModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfShareScreenUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfSignalChannelScreenModel : NSObject

//  1共享 0不共享
@property (nonatomic, assign) NSInteger shareScreen;
@property (nonatomic, strong) NSArray<ConfShareScreenUserModel*> *shareScreenUsers;

@end

NS_ASSUME_NONNULL_END
