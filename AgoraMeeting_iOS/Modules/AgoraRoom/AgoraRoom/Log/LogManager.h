//
//  LogManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/3/24.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "AREnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface LogManager : NSObject

+ (void)debug:(NSString *)text;
+ (void)info:(NSString *)text;
+ (void)error:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
