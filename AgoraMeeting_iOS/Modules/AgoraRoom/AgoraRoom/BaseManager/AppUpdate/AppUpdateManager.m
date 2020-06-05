//
//  AppUpdateManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/31.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "AppUpdateManager.h"
#import "HttpManager.h"
#import "URL.h"
#import "ConfigModel.h"

#define ITUNES_URL @"https://itunes.apple.com/cn/app/id1515428313"
 
@interface AppUpdateManager()<UIApplicationDelegate>

@end

static AppUpdateManager *manager = nil;

@implementation AppUpdateManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if(self = [super init]){
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)checkAppUpdate {
    [HttpManager getConfigWithApiVersion:@"v1" successBolck:^(ConfigAllInfoModel * _Nonnull model) {
        
        if(model.forcedUpgrade == 2) {
           [AppUpdateManager.shareManager showAppUpdateAlertView:NO];
        } else if(model.forcedUpgrade == 3) {
           [AppUpdateManager.shareManager showAppUpdateAlertView:YES];
        }
        
    } completeFailBlock:^(NSError * _Nonnull error) {
        
    }];
}

- (void)showAppUpdateAlertView:(BOOL)force {
    
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    UINavigationController *nvc = (UINavigationController*)window.rootViewController;
    if(nvc != nil){
        UIViewController *showController = nvc;
        if(nvc.visibleViewController != nil){
            showController = nvc.visibleViewController;
        }
        
        NSURL *url = [NSURL URLWithString:ITUNES_URL];
        
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:Localized(@"UpdateText") message:nil preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *actionDone = [UIAlertAction actionWithTitle:Localized(@"OKText") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertVc addAction:actionDone];
        if(!force){
            
            UIAlertAction *actionCacncel = [UIAlertAction actionWithTitle:Localized(@"CancelText") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertVc addAction:actionCacncel];
        }
        [showController presentViewController:alertVc animated:YES completion:nil];
    }
}

- (void)applicationWillEnterForeground {
    [AppUpdateManager.shareManager checkAppUpdate];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end

