//
//  BaseViewController.h
//  VideoConference
//
//  Created by SRS on 2020/5/7.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

- (void)showToast:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
