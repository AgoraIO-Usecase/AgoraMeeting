//
//  AllMuteAlertVC.h
//  VideoConference
//
//  Created by SRS on 2020/5/15.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ContinueBlock)(BOOL allowUnmute);

NS_ASSUME_NONNULL_BEGIN

@interface AllMuteAlertVC : UIViewController

@property (copy, nonatomic) ContinueBlock block;

@end

NS_ASSUME_NONNULL_END
