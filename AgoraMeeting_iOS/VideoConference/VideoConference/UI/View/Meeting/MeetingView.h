//
//  MeetingView.h
//  VideoConference
//
//  Created by ZYP on 2020/12/28.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingViewDelegate.h"

@class MeetingTopView, MeetingBottomView, VideoScrollView, SpeakerView, MeetingFlowLayoutVideo, MeetingFlowLayoutAudio, MeetingFlowLayoutVideoScroll, MeetingMessageView;
typedef NS_ENUM(NSUInteger, MeetingViewMode) {
    // 视频平铺模式
    MeetingViewModeVideoFlow,
    // 语音平铺模式
    MeetingViewModeAudioFlow,
    // 演讲者模式
    MeetingViewModeSpeaker,
};
NS_ASSUME_NONNULL_BEGIN

@interface MeetingView : UIView

@property (nonatomic, strong)MeetingTopView *topView;
@property (nonatomic, strong)MeetingBottomView *bottomView;
@property (nonatomic, strong)UICollectionView *collectionViewVideo;
@property (nonatomic, strong)UICollectionView *collectionViewAudio;
@property (nonatomic, strong)VideoScrollView *videoScrollView;
@property (nonatomic, strong)SpeakerView *speakerView;
@property (nonatomic, strong)MeetingMessageView *messageView;
@property (nonatomic, strong)MeetingFlowLayoutVideo *layoutVideo;
@property (nonatomic, strong)MeetingFlowLayoutAudio *layoutAudio;
@property (nonatomic, strong)MeetingFlowLayoutVideoScroll *layoutVideoScroll;
@property (nonatomic, weak)id<MeetingViewDelegate> delegate;

- (void)setMode:(MeetingViewMode)mode infosCunt:(NSInteger)infosCunt showRightButton:(BOOL)showRightButton;
- (MeetingViewMode)getMode;
- (void)updatePage;

@end

NS_ASSUME_NONNULL_END
