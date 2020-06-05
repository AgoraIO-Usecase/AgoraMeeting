//
//  BaseSignalModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseSignalModel : NSObject

@property (nonatomic, assign) NSInteger cmd;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger timestamp;

@end

NS_ASSUME_NONNULL_END
