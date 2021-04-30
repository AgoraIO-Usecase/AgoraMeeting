//
//  BottomItem.h
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BottomItemBlock)(void);

typedef NS_ENUM(NSUInteger, BottomItemState) {
    BottomItemStateActive = 0,
    BottomItemStateInactive = 1,
    BottomItemStateTime = 2,
    BottomItemStateRedDot = 3,
};

NS_ASSUME_NONNULL_BEGIN


@interface BottomItemInfo : NSObject

@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *activeImageName;
@property (nonatomic, copy)NSString *inActiveImageName;
@property (nonatomic, strong)UIColor *inActiveTextColor;
@property (nonatomic, strong)UIColor *activeTextColor;

@end


@interface BottomItem : UIView

@property (copy, nonatomic) BottomItemBlock block;

- (void)configInfo:(BottomItemInfo *)info;
- (void)configState:(BottomItemState)state timeCount:(NSInteger)timeCount;
- (BottomItemState)getState;
- (void)setRedDoc:(NSInteger)count;
- (void)setButtonEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
