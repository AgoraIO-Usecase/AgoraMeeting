//
//  UIImage+Circle.h
//  VideoConference
//
//  Created by SRS on 2020/5/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Circle)

+ (UIImage *)generateImageWithSize:(CGSize)size;
+ (UIImage *)circleImageWithOriginalImage:(UIImage *)originalImage;

@end

NS_ASSUME_NONNULL_END
