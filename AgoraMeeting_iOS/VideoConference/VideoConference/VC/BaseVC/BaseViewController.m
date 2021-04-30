//
//  BaseViewController.m
//  VideoConference
//
//  Created by SRS on 2020/5/7.
//  Copyright © 2020 agora. All rights reserved.
//

#import "BaseViewController.h"
#import "VCManager.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"F8F9FB"];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    activityIndicator.frame= CGRectMake((kScreenWidth -100)/2, (kScreenHeight - 100)/2 - 100, 100, 100);
    activityIndicator.color = [UIColor grayColor];
    activityIndicator.backgroundColor = [UIColor clearColor];
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;
}

- (void)showToast:(NSString *)title {
    [self showToastCenter:title];
}

- (void)showToastCenter:(NSString *)title {
    UIViewController *vc = [VCManager getTopVC];
    if (vc != nil && title != nil && title.length > 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc.view makeToast:title duration:1.5 position:CSToastPositionCenter];
        });
    }
}

- (void)showLoading {
    [_activityIndicator startAnimating];
}

- (void)dismissLoading {
    [_activityIndicator stopAnimating];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
