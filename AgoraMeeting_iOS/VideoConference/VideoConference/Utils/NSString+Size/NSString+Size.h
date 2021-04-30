//
//  NSString+Size.h
//  VideoConference
//
//  Created by ZYP on 2021/4/10.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Size)

- (CGSize)sizeWithString:(NSString *)string Font:(UIFont *)font maxSize:(CGSize)maxSize;

@end

NS_ASSUME_NONNULL_END
