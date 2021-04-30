//
//  HMRespone.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/21.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMRespone : NSObject

@property(nonatomic, assign)NSInteger code;
@property(nonatomic, copy)NSString *msg;
@property(nonatomic, strong)id data;

@end

NS_ASSUME_NONNULL_END
