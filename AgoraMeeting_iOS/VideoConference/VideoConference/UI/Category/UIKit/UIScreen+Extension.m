//
//  UIScreen+Extension.m
//  VideoConference
//
//  Created by ZYP on 2020/12/29.
//  Copyright © 2020 agora. All rights reserved.
//

#import "UIScreen+Extension.h"

@implementation UIScreen (Extension)

+ (BOOL)supportFaceID
{
    float statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;

    if (statusHeight > 20){
        return YES;

    } else{
        return NO;
    }
}

+ (CGFloat)statusBarHeight
{
    return  [[UIApplication sharedApplication] statusBarFrame].size.height;
}

+ (CGFloat)bottomSafeAreaHeight
{
    return [self supportFaceID] ? 34 : 0;
}

+ (CGFloat)topSafeAreaHeight
{
    return [self statusBarHeight] - 20;
}


@end
