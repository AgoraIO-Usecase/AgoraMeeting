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

@protocol BottomBarDelegate <NSObject>
- (void)onScreenShareStart;
- (void)onScreenShareEnd;
@end


@interface BottomBar : UIView

- (void)updateView;
- (void)addUnreadMsgCount;
@property(nonatomic,weak) id<BottomBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
