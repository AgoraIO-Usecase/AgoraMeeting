//
//  NavigationController.m
//  VideoConference
//
//  Created by ZYP on 2021/1/18.
//  Copyright © 2021 agora. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setHidden:false];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, 0) forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.tintColor = [UIColor colorWithHex:0x323C47];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHex:0x030303]}];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}


@end
