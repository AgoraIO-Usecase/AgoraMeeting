//
//  VCManager.m
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import "VCManager.h"

static VCManager *manager = nil;

@implementation VCManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VCManager alloc] init];
    });
    return manager;
}

+ (UINavigationController *)getNavC {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    UINavigationController *nvc = (UINavigationController*)window.rootViewController;
    return nvc;
}

+ (UIViewController *)getTopVC {
    UINavigationController *nvc = [VCManager getNavC];
    if(nvc != nil){
        return nvc.visibleViewController;
    }
    return nil;
}

+ (void)pushToVC:(UIViewController *)targetVC {
    
    UINavigationController *nvc = [VCManager getNavC];
    if(nvc != nil){
        [nvc pushViewController:targetVC animated:YES];
    }
}

+ (void)popTopView {
    UINavigationController *nvc = [VCManager getNavC];
    if(nvc != nil){
        [nvc popViewControllerAnimated:YES];
    }
}

+ (void)popRootView {
    UINavigationController *nvc = [VCManager getNavC];
    if([nvc.visibleViewController isKindOfClass:[UIAlertController class]]) {
        [nvc dismissViewControllerAnimated:NO completion:^{
            [nvc popToRootViewControllerAnimated:YES];
        }];
    } else {
        [nvc popToRootViewControllerAnimated:YES];
    }
}

+ (void)presentToVC:(UIViewController *)targetVC {
    UINavigationController *nvc = [VCManager getNavC];
    targetVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    if(nvc != nil){
        [nvc.visibleViewController presentViewController:targetVC animated:YES completion:nil];
    }
}

+ (void)dismissView {
    UIViewController *vc = [VCManager getTopVC];
    [vc dismissViewControllerAnimated:YES completion:nil];
}

@end
