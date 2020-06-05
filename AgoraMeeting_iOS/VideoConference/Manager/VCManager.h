//
//  VCManager.h
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCManager : NSObject

+ (UIViewController *)getTopVC;

+ (void)pushToVC:(UIViewController *)targetVC;
+ (void)popTopView;
+ (void)popRootView;

+ (void)presentToVC:(UIViewController *)targetVC;
+ (void)dismissView;

@end

NS_ASSUME_NONNULL_END
