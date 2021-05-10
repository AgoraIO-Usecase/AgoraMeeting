//
//  NSString+Size.m
//  VideoConference
//
//  Created by ZYP on 2021/4/10.
//  Copyright © 2021 agora. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)


- (CGSize)sizeWithString:(NSString *)string Font:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

@end
