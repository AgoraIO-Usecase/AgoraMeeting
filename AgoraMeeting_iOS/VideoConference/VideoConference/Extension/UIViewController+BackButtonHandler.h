//
//  UIViewController+BackButtonHandler.h
//  VideoConference
//
//  Created by ZYP on 2021/4/8.
//  Copyright © 2021 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// UIViewController+BackButtonHandler.h
@protocol BackButtonHandlerProtocol <NSObject>
@optional
// 重写下面的方法以拦截导航栏返回按钮点击事件，返回 YES 则 pop，NO 则不 pop
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (BackButtonHandler) <BackButtonHandlerProtocol>

@end

NS_ASSUME_NONNULL_END
