//
//  ShareLinkView.h
//  VideoConference
//
//  Created by SRS on 2020/5/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareLinkView : UIView

+ (instancetype)createViewWithXib;
- (void)showShareLinkViewInView:(UIView *)inView;
- (void)hiddenShareLinkView;

@end

NS_ASSUME_NONNULL_END
