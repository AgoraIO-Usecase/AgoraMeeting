//
//  ConfShareScreenUserModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfShareScreenUserModel : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) NSInteger role;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger screenId;

@end

NS_ASSUME_NONNULL_END
