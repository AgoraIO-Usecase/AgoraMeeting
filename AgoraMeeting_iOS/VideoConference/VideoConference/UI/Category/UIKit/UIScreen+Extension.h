//
//  UIScreen+Extension.h
//  VideoConference
//
//  Created by ZYP on 2020/12/29.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (Extension)

+ (BOOL)supportFaceID;
+ (CGFloat)statusBarHeight;
+ (CGFloat)bottomSafeAreaHeight;
+ (CGFloat)topSafeAreaHeight;

@end

NS_ASSUME_NONNULL_END
