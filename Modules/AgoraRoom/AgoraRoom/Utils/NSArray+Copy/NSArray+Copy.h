//
//  NSArray+Copy.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/24.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Copy)

- (NSArray *)deepCopy;

@end

NS_ASSUME_NONNULL_END
