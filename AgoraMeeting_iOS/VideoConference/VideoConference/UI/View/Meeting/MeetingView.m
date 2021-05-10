//
//  MeetingView.m
//  VideoConference
//
//  Created by ZYP on 2020/12/28.
//  Copyright © 2020 agora. All rights reserved.
//

#import "MeetingView.h"
#import "MeetingTopView.h"
#import "MeetingBottomView.h"
#import "UIScreen+Extension.h"
#import "VideoScrollView.h"
#import "SpeakerView.h"
#import "MeetingFlowLayoutVideo.h"
#import "MeetingFlowLayoutAudio.h"
#import "PageCtrlView.h"
#import "MeetingViewDelegate.h"
#import "MeetingFlowLayoutVideoScroll.h"
#import "MeetingMessageView.h"
#import "UIColor+AppColor.h"

@interface MeetingView ()<MeetingMessageViewUIDelegate>{
    NSLayoutConstraint *_messageViewBottomConstraint;
    NSLayoutConstraint *_messageViewHeightConstraint, *_messageViewWidthConstraint;
}

@property (nonatomic, assign)MeetingViewMode mode;
@property (nonatomic, strong)PageCtrlView *pageCtrlView;

@end

static const CGFloat MessageViewBottomConstantHeigh = -125;
static const CGFloat MessageViewBottomConstantLow = -25;

@implementation MeetingView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
        [self layout];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = UIColor.whiteColor;
    _topView = [MeetingTopView instanceFromNib];
    _bottomView = [MeetingBottomView instanceFromNib];

    _layoutVideo = [MeetingFlowLayoutVideo new];
    _layoutAudio = [MeetingFlowLayoutAudio new];
    _layoutVideoScroll = [MeetingFlowLayoutVideoScroll new];
    
    _collectionViewVideo = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layoutVideo];
    _collectionViewVideo.backgroundColor = [UIColor colorWithHex:0x353636];
    [_collectionViewVideo setPagingEnabled:true];
    _collectionViewVideo.showsHorizontalScrollIndicator = false;
    
    _collectionViewAudio = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layoutAudio];
    _collectionViewAudio.backgroundColor = [UIColor colorWithHex:0x353636];
    [_collectionViewAudio setPagingEnabled:true];
    _collectionViewAudio.showsHorizontalScrollIndicator = false;
    

    _videoScrollView = [VideoScrollView new];
    [_videoScrollView.collectionView setCollectionViewLayout:_layoutVideoScroll];
    _videoScrollView.collectionView.showsHorizontalScrollIndicator = false;
    
    _speakerView = [SpeakerView new];
    _pageCtrlView = [PageCtrlView instanceFromNib];
    
    _messageView = [MeetingMessageView new];
    _messageView.uiDelegate = self;
    
    [self addSubview:_collectionViewVideo];
    [self addSubview:_collectionViewAudio];
    [self addSubview:_topView];
    [self addSubview:_bottomView];
    [self addSubview:_speakerView];
    [self addSubview:_pageCtrlView];
    [self addSubview:_videoScrollView];
    [self addSubview:_messageView];
    
}

- (void)layout {
    _topView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_topView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_topView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_topView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_topView.heightAnchor constraintEqualToConstant:44+UIScreen.statusBarHeight]
    ]];
    
    _bottomView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_bottomView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_bottomView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor ],
        [_bottomView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_bottomView.heightAnchor constraintEqualToConstant:55+UIScreen.bottomSafeAreaHeight]
    ]];
    
    _collectionViewVideo.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_collectionViewVideo.topAnchor constraintEqualToAnchor:_topView.bottomAnchor],
        [_collectionViewVideo.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_collectionViewVideo.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_collectionViewVideo.bottomAnchor constraintEqualToAnchor:_bottomView.topAnchor]
    ]];
    
    _collectionViewAudio.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_collectionViewAudio.topAnchor constraintEqualToAnchor:_topView.bottomAnchor],
        [_collectionViewAudio.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_collectionViewAudio.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_collectionViewAudio.bottomAnchor constraintEqualToAnchor:_bottomView.topAnchor]
    ]];
    
    _pageCtrlView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_pageCtrlView.widthAnchor constraintEqualToConstant:80],
        [_pageCtrlView.heightAnchor constraintEqualToConstant:20],
        [_pageCtrlView.bottomAnchor constraintEqualToAnchor:_collectionViewVideo.bottomAnchor constant:-15],
        [_pageCtrlView.centerXAnchor constraintEqualToAnchor:_collectionViewVideo.centerXAnchor]
    ]];
    
    _speakerView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_speakerView.topAnchor constraintEqualToAnchor:_topView.bottomAnchor],
        [_speakerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_speakerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_speakerView.bottomAnchor constraintEqualToAnchor:_bottomView.topAnchor]
    ]];
    
    _videoScrollView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_videoScrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_videoScrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_videoScrollView.bottomAnchor constraintEqualToAnchor:_bottomView.topAnchor],
        [_videoScrollView.heightAnchor constraintEqualToConstant:120]
    ]];
    
    _messageView.translatesAutoresizingMaskIntoConstraints = false;
    _messageViewBottomConstraint = [_messageView.bottomAnchor constraintEqualToAnchor:_videoScrollView.bottomAnchor constant:MessageViewBottomConstantLow];
    _messageViewHeightConstraint = [_messageView.heightAnchor constraintEqualToConstant:147];
    _messageViewWidthConstraint =  [_messageView.widthAnchor constraintEqualToConstant:190];
    [NSLayoutConstraint activateConstraints:@[
        [_messageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        _messageViewWidthConstraint,
        _messageViewBottomConstraint,
        _messageViewHeightConstraint,
    ]];
    
}

- (void)setMode:(MeetingViewMode)mode infosCunt:(NSInteger)infosCunt showRightButton:(BOOL)showRightButton {
    _mode = mode;
    
    switch (_mode) {
        case MeetingViewModeVideoFlow:
            {
                [self->_videoScrollView setHidden:true];
                [self->_speakerView setHidden:true];
                [self->_collectionViewAudio setHidden:true];
                [self->_collectionViewVideo setHidden:false];
                [self invalidCollectionViewLayoutIfNeed:self->_collectionViewVideo];
                [self->_speakerView.rightButton setHidden:true];
                [self updatePage];
                [self layoutIfNeeded];
                _messageViewBottomConstraint.constant = MessageViewBottomConstantLow;
                [UIView animateWithDuration:0.25 animations:^{
                    [self layoutIfNeeded];
                }];
            }
            break;
        case MeetingViewModeAudioFlow:
            {
                [self->_videoScrollView setHidden:true];
                [self->_speakerView setHidden:true];
                [self->_collectionViewVideo setHidden:true];
                [self->_collectionViewAudio setHidden:false];
                [self->_collectionViewAudio reloadData];
                [self invalidCollectionViewLayoutIfNeed:self->_collectionViewAudio];
                [self->_speakerView.rightButton setHidden:true];
                [self updatePage];
                [self layoutIfNeeded];
                _messageViewBottomConstraint.constant = MessageViewBottomConstantLow;
                [UIView animateWithDuration:0.25 animations:^{
                    [self layoutIfNeeded];
                }];
            }
            break;
        case MeetingViewModeSpeaker:
            {
                [self->_videoScrollView setHidden:infosCunt == 0 ? true : false];
                [self->_speakerView setHidden:false];
                [self->_collectionViewVideo setHidden:true];
                [self->_collectionViewAudio setHidden:true];
                [self->_speakerView.rightButton setHidden:showRightButton];
                [self updatePage];
                [self layoutIfNeeded];
                _messageViewBottomConstraint.constant = infosCunt == 0 ? MessageViewBottomConstantLow : MessageViewBottomConstantHeigh;
                [UIView animateWithDuration:0.25 animations:^{
                    [self layoutIfNeeded];
                }];
            }
            break;
        default:
            break;
    }
}

- (void)invalidCollectionViewLayoutIfNeed:(UICollectionView *)collectionView {
    double systemVersion = UIDevice.currentDevice.systemVersion.doubleValue;
    if (systemVersion >= 12.0 && systemVersion < 13.0) {
        [collectionView.collectionViewLayout invalidateLayout];
    }
}

- (MeetingViewMode)getMode {
    return _mode;
}

- (void)updatePage {
    MeetingViewMode mode = [self getMode];
    if (mode == MeetingViewModeSpeaker) {
        [self.pageCtrlView setHidden:true];
        return;
    }
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    switch (mode) {
        case MeetingViewModeVideoFlow:
        {
            NSUInteger x = self.collectionViewVideo.contentOffset.x;
            NSInteger index = x/screenWidth;
            NSInteger pages = self.collectionViewVideo.contentSize.width/screenWidth;
            [_pageCtrlView setcCurrentPage:index andNumberOfPage:pages];
        }
        break;
        case MeetingViewModeAudioFlow:
        {
            NSUInteger x = self.collectionViewAudio.contentOffset.x;
            NSInteger index = x/screenWidth;
            NSInteger pages = self.collectionViewAudio.contentSize.width/screenWidth;
            [_pageCtrlView setcCurrentPage:index andNumberOfPage:pages];
        }
        break;
            break;
        default:
            [self.pageCtrlView setHidden:true];
            break;
    }
}


#pragma mark - MeetingMessageViewUIDelegate

- (void)messageViewShouldUpdateSize:(CGSize)size {
    _messageViewHeightConstraint.constant = size.height;
    _messageViewWidthConstraint.constant = size.width;
    [self layoutIfNeeded];
}

@end
