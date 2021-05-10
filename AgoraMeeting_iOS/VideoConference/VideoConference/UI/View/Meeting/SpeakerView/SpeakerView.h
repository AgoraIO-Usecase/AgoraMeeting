//
//  SpeakerView.h
//  VideoConference
//
//  Created by ZYP on 2020/12/29.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RightButtonActionType) {
    RightButtonActionTypeChangeMode = 0,
    RightButtonActionTypeWhiteBoardEnter = 1,
    RightButtonActionTypeScreenShareQuit = 2,
};

@class SpeakerLeftItem, SpeakerModel, WhiteBoardView;

@protocol SpeakerViewDelegate <NSObject>

- (void)speakerViewDidTapRightButton:(RightButtonActionType)action;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SpeakerView : UIView

@property (nonatomic, strong)UIButton *rightButton;
@property (nonatomic, strong)UIButton *closeScreenShareButton;
@property (nonatomic, strong)SpeakerLeftItem *leftItem;
@property (nonatomic, strong)UIButton *boardButton;
@property (nonatomic, weak)id<SpeakerViewDelegate> delegate;

- (UIView *)getVideoView;
- (WhiteBoardView *)getBoardView;
- (void)setModel:(SpeakerModel *)model;
- (void)updateScaleVideoViewContentSize;

@end

NS_ASSUME_NONNULL_END
