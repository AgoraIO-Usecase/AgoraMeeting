//
//  UIColor+AppColor.h
//  VideoConference
//
//  Created by ZYP on 2020/12/31.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (AppColor)

+ (UIColor *)floatViewBackground;
+ (UIColor *)themColor;
+ (UIColor *)textColor;
+ (NSArray *)convertColorToRGB:(UIColor *)color;

@end


NS_ASSUME_NONNULL_END
