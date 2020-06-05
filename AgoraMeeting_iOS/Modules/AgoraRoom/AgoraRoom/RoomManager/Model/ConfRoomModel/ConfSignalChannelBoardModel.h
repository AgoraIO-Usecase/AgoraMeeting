//
//  ConfSignalChannelBoardModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfShareBoardUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfSignalChannelBoardModel : NSObject

//  1共享 0不共享
@property (nonatomic, assign) NSInteger shareBoard;
@property (nonatomic, strong) NSString *createBoardUserId;
@property (nonatomic, strong) NSArray<ConfShareBoardUserModel*> *shareBoardUsers;

@end


NS_ASSUME_NONNULL_END
