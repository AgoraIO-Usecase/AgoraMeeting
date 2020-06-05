//
//  BottomBar.h
//  VideoConference
//
//  Created by SRS on 2020/5/7.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface BottomBar : UIView

- (void)updateView;
- (void)addUnreadMsgCount;

@end

NS_ASSUME_NONNULL_END
