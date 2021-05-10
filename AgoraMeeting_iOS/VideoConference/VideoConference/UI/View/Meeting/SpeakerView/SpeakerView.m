//
//  SpeakerView.m
//  VideoConference
//
//  Created by ZYP on 2020/12/29.
//  Copyright © 2020 agora. All rights reserved.
//

#import "SpeakerView.h"
#import "SpeakerLeftItem.h"
#import "SpeakerModel.h"
#import <Whiteboard/Whiteboard.h>
#import <WhiteModule/WhiteManager.h>
#import "UIColor+AppColor.h"
#import "ScaleVideoView.h"
#import "NSString+Size.h"

/// 演讲者视图
@interface SpeakerView ()

@property (nonatomic, strong)ScaleVideoView *videoScaleView;
@property (nonatomic, strong)UIView *boardView;
@property (nonatomic, strong)UILabel *tipLabel;
@property (nonatomic, strong)NSLayoutConstraint *leftItemWidthConstraint;
@end

@implementation SpeakerView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
        [self commonInit];
        [self layout];
    }
    return self;
}

- (void)setup {
    
    _leftItem = [SpeakerLeftItem instanceFromNib];
    _rightButton = [UIButton new];
    _closeScreenShareButton = [UIButton new];
    _videoScaleView = [ScaleVideoView new];
    _boardView = [WhiteManager createWhiteBoardView];
    _boardButton = [UIButton new];
    _tipLabel = [UILabel new];
    
    UIImage *image = [UIImage imageNamed:@"平铺视图"];
    [_rightButton setImage:image forState:UIControlStateNormal];
    [_closeScreenShareButton setTitle:NSLocalizedString(@"ui_t7", @"") forState:UIControlStateNormal];
    [_closeScreenShareButton setBackgroundColor:[UIColor colorWithHex:0xFF5F51]];
    [_closeScreenShareButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _closeScreenShareButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _closeScreenShareButton.layer.cornerRadius = 2;
    _closeScreenShareButton.layer.masksToBounds = true;
    [_boardButton setBackgroundColor:UIColor.themColor];
    [_boardButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_boardButton setTitle:NSLocalizedString(@"ui_t8", @"") forState:UIControlStateNormal];
    [_boardButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_boardButton setHidden:true];
    _boardButton.layer.cornerRadius = 2;
    _boardButton.layer.masksToBounds = true;
    [_videoScaleView setBackgroundColor:[UIColor colorWithHex:0x353636]];
    _videoScaleView.tag = 10086;
    _tipLabel.text = NSLocalizedString(@"ui_t3", @"");
    _tipLabel.textColor = UIColor.whiteColor;
    
    [self addSubview:_boardView];
    [self addSubview:_videoScaleView];
    [self addSubview:_leftItem];
    [self addSubview:_rightButton];
    [self addSubview:_boardButton];
    [self addSubview:_tipLabel];
    [self addSubview:_closeScreenShareButton];
    
    self.backgroundColor = [UIColor colorWithHex:0x353636];
}

- (void)commonInit {
    [_rightButton addTarget:self
                     action:@selector(buttonTap:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [_boardButton addTarget:self
                     action:@selector(buttonTap:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [_closeScreenShareButton addTarget:self
                                action:@selector(buttonTap:)
                      forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)layout {
    
    _videoScaleView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_videoScaleView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
        [_videoScaleView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
        [_videoScaleView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0],
        [_videoScaleView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0]
    ]];
    
    _boardView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_boardView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
        [_boardView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
        [_boardView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0],
        [_boardView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0]
    ]];
    
    _leftItem.translatesAutoresizingMaskIntoConstraints = false;
    NSLayoutConstraint *leftItemWidthConstraint = [_leftItem.widthAnchor constraintEqualToConstant:100];
    [NSLayoutConstraint activateConstraints:@[
        [_leftItem.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15.0],
        [_leftItem.topAnchor constraintEqualToAnchor:self.topAnchor constant:10.0],
        [_leftItem.heightAnchor constraintEqualToConstant:22],
        leftItemWidthConstraint,
    ]];
    _leftItemWidthConstraint = leftItemWidthConstraint;
    
    _rightButton.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_rightButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20.0],
        [_rightButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:10.0],
    ]];
    
    _boardButton.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_boardButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20.0],
        [_boardButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:20.0],
        [_boardButton.widthAnchor constraintGreaterThanOrEqualToConstant:96],
        [_boardButton.heightAnchor constraintEqualToConstant:30]
    ]];
    
    _tipLabel.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_tipLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_tipLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
    ]];
    
    _closeScreenShareButton.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_closeScreenShareButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20.0],
        [_closeScreenShareButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:20.0],
        [_closeScreenShareButton.heightAnchor constraintEqualToConstant:30],
        [_closeScreenShareButton.widthAnchor constraintGreaterThanOrEqualToConstant:82]
    ]];
}

- (UIView *)getVideoView {
    return  _videoScaleView.videoView;
}

- (UIView *)getBoardView {
    return  _boardView;
}

- (void)setModel:(SpeakerModel *)model {
    [_leftItem setModel:model];
    [self updateLeftItemWidth:model];
    
    switch (model.type) {
        case SpeakerModelTypeVideo:
            [_closeScreenShareButton setHidden:true];
            _boardButton.hidden = true;
            _videoScaleView.hidden = false;
            _boardView.hidden = true;
            _tipLabel.hidden = true;
            break;
        case SpeakerModelTypeScreen:
            _boardButton.hidden = true;
            if (model.isLocalUser) {
                [_closeScreenShareButton setHidden:false];
                _tipLabel.hidden = false;
                _videoScaleView.hidden = true;
                _boardView.hidden = true;
            }
            else {
                [_closeScreenShareButton setHidden:true];
                _tipLabel.hidden = true;
                _videoScaleView.hidden = false;
                _boardView.hidden = true;
            }
            break;
        case SpeakerModelTypeBoard:
            [_closeScreenShareButton setHidden:true];
            _boardButton.hidden = false;
            _tipLabel.hidden = true;
            _videoScaleView.hidden = true;
            _boardView.hidden = false;
            break;
        default:
            break;
    }
}

- (void)buttonTap:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(speakerViewDidTapRightButton:)]) {
        RightButtonActionType type = RightButtonActionTypeChangeMode;
        if (btn == _boardButton) {
            type = RightButtonActionTypeWhiteBoardEnter;
        }
        if (btn == _closeScreenShareButton) {
            type = RightButtonActionTypeScreenShareQuit;
        }
        [_delegate speakerViewDidTapRightButton:type];
    }
}

- (void)updateScaleVideoViewContentSize {
    [_videoScaleView configContentSize:self.bounds.size];
}

- (void)updateLeftItemWidth:(SpeakerModel *)model {
    BOOL noShare = model.type == SpeakerModelTypeVideo;
    CGFloat nameLen = [model.name sizeWithString:model.name
                                            Font:[UIFont systemFontOfSize:12]
                                         maxSize:CGSizeMake(100, 25)].width;
    CGFloat len = (noShare ? 0 : 22) + (model.isHost ? 22 : 0) + 22 + nameLen + 5;
    _leftItemWidthConstraint.constant = len;
    [self layoutIfNeeded];
}


@end
