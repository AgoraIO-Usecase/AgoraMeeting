//
//  VideoCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/15.
//  Copyright © 2020 agora. All rights reserved.
//

#import "VideoCell.h"
#import "UIImage+Circle.h"

@interface VideoCell ()

@property (nonatomic, strong) UIView *renderViewWapper;
@property (nonatomic, strong) UIView *renderView;
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UIImageView *hostView;
@property (nonatomic, strong) UIImageView *shareView;
@property (nonatomic, strong) UIImageView *audioView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) NSLayoutConstraint *hostViewWidth;
@property (nonatomic, strong) NSLayoutConstraint *shareViewWidth;
@property (nonatomic, strong) NSLayoutConstraint *audioViewWidth;


@end


@implementation VideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    _renderViewWapper = [UIView new];
    _maskView = [UIImageView new];
    _headImageView = [UIImageView new];
    _shareView = [UIImageView new];
    _hostView = [UIImageView new];
    _audioView = [UIImageView new];
    _nameLabel = [UILabel new];
    
    UIImage *image = [UIImage generateImageWithSize:CGSizeMake(32, 32)];
    image = [UIImage circleImageWithOriginalImage:image];
    _headImageView.image = image;
    
    _shareView.image = [UIImage imageNamed:@"state-share"];
    _hostView.image = [UIImage imageNamed:@"state-host"];
    
    _nameLabel.font = [UIFont systemFontOfSize:11];
    _nameLabel.textColor = UIColor.whiteColor;
    
    [self.contentView addSubview:_renderViewWapper];
    [self.contentView addSubview:_maskView];
    [self.contentView addSubview:_headImageView];
    [self.contentView addSubview:_hostView];
    [self.contentView addSubview:_shareView];
    [self.contentView addSubview:_audioView];
    [self.contentView addSubview:_nameLabel];
    
    _renderViewWapper.translatesAutoresizingMaskIntoConstraints = false;
    _maskView.translatesAutoresizingMaskIntoConstraints = false;
    _headImageView.translatesAutoresizingMaskIntoConstraints = false;
    _shareView.translatesAutoresizingMaskIntoConstraints = false;
    _hostView.translatesAutoresizingMaskIntoConstraints = false;
    _audioView.translatesAutoresizingMaskIntoConstraints = false;
    _nameLabel.translatesAutoresizingMaskIntoConstraints = false;
    
    NSLayoutConstraint *renderViewWapperTop = [_renderViewWapper.topAnchor constraintEqualToAnchor:self.contentView.topAnchor];
    NSLayoutConstraint *renderViewWapperBottom = [_renderViewWapper.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor];
    NSLayoutConstraint *renderViewWapperLeft = [_renderViewWapper.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor];
    NSLayoutConstraint *renderViewWapperRight = [_renderViewWapper.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor];
    [NSLayoutConstraint activateConstraints:@[renderViewWapperTop, renderViewWapperBottom, renderViewWapperLeft, renderViewWapperRight]];

    NSLayoutConstraint *maskViewTop = [_maskView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor];
    NSLayoutConstraint *maskViewBottom = [_maskView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor];
    NSLayoutConstraint *maskViewLeft = [_maskView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor];
    NSLayoutConstraint *maskViewRight = [_maskView.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor];
    [NSLayoutConstraint activateConstraints:@[maskViewTop, maskViewBottom, maskViewLeft, maskViewRight]];

    NSLayoutConstraint *headImageViewCenterX = [_headImageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor];
    NSLayoutConstraint *headImageViewCenterY = [_headImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor];
    NSLayoutConstraint *headImageViewWidth = [_headImageView.heightAnchor constraintEqualToConstant:32];
    NSLayoutConstraint *headImageViewHeight = [_headImageView.widthAnchor constraintEqualToConstant:32];
    [NSLayoutConstraint activateConstraints:@[headImageViewCenterX, headImageViewCenterY, headImageViewWidth, headImageViewHeight]];

    NSLayoutConstraint *hostViewLeft = [_hostView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor];
    NSLayoutConstraint *hostViewBottom = [_hostView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-3];
    NSLayoutConstraint *hostViewHeight = [_hostView.heightAnchor constraintEqualToConstant:17];
    NSLayoutConstraint *hostViewWidth = [_hostView.widthAnchor constraintEqualToConstant:17];
    _hostViewWidth = hostViewWidth;
    [NSLayoutConstraint activateConstraints:@[hostViewLeft, hostViewBottom, hostViewHeight, hostViewWidth]];

    NSLayoutConstraint *shareViewLeft = [_shareView.leftAnchor constraintEqualToAnchor:_hostView.rightAnchor constant:3];
    NSLayoutConstraint *shareViewBottom = [_shareView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-3];
    NSLayoutConstraint *shareViewHeight = [_shareView.heightAnchor constraintEqualToConstant:17];
    NSLayoutConstraint *shareViewWidth = [_shareView.widthAnchor constraintEqualToConstant:17];
    [NSLayoutConstraint activateConstraints:@[shareViewLeft, shareViewBottom, shareViewHeight, shareViewWidth]];
    _shareViewWidth = shareViewWidth;

    NSLayoutConstraint *audioViewLeft = [_audioView.leftAnchor constraintEqualToAnchor:_shareView.rightAnchor constant:3];
    NSLayoutConstraint *audioViewBottom = [_audioView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-3];
    NSLayoutConstraint *audioViewHeight = [_audioView.heightAnchor constraintEqualToConstant:17];
    NSLayoutConstraint *audioViewWidth = [_audioView.widthAnchor constraintEqualToConstant:17];
    [NSLayoutConstraint activateConstraints:@[audioViewLeft, audioViewBottom, audioViewHeight, audioViewWidth]];
    _audioViewWidth = audioViewWidth;

    NSLayoutConstraint *nameLabelLeft = [_nameLabel.leftAnchor constraintEqualToAnchor:self.audioView.rightAnchor constant:3];
    NSLayoutConstraint *nameLabelCenterY = [_nameLabel.centerYAnchor constraintEqualToAnchor:self.audioView.centerYAnchor];
    NSLayoutConstraint *nameLabelRight = [_nameLabel.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor];
    [NSLayoutConstraint activateConstraints:@[nameLabelLeft, nameLabelCenterY, nameLabelRight]];

}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}


- (void)setShareBoardModel:(ConfShareBoardUserModel *)userModel {}

- (void)setShareScreenModel:(ConfShareScreenUserModel *)userModel {}

- (void)setUserModel:(ConfUserModel * _Nullable)userModel {
    if(userModel == nil){
        self.hidden = YES;
        return;
    }
     self.hidden = NO;
    [self addRenderViewIfNeed];
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    
    if (userModel.enableVideo) {
        [manager addVideoCanvasWithUId:userModel.uid inView:self.renderView];
        self.renderView.hidden = NO;
        self.headImageView.hidden = YES;
    } else {
        [manager removeVideoCanvasWithView:self.renderView];
        self.headImageView.hidden = NO;
        self.renderView.hidden = YES;
    }

    self.nameLabel.text = userModel.userName;
    if(userModel.role == ConfRoleTypeHost) {
        self.hostView.hidden = NO;
        self.hostViewWidth.constant = 17;
    } else {
        self.hostView.hidden = YES;
        self.hostViewWidth.constant = 0;
    }

    if(userModel.grantBoard || userModel.grantScreen) {
        self.shareView.hidden = NO;
        self.shareViewWidth.constant = 17;
        
    } else {
        self.shareView.hidden = YES;
        self.shareViewWidth.constant = 0;
        self.hostViewWidth.constant = 0;
    }

    self.audioView.hidden = NO;
    if(userModel.enableAudio) {
        self.audioView.image = [UIImage imageNamed:@"state-unmute"];
    } else {
        self.audioView.image = [UIImage imageNamed:@"state-mute"];
    }
}

- (void)addRenderViewIfNeed {
    
    if (self.renderView != nil) {
        [self.renderView removeFromSuperview];
    }
    self.renderView = [UIView new];
    self.renderView.tag = 10086;
    [self.renderView setBackgroundColor:[UIColor grayColor]];
    [self.renderViewWapper addSubview:self.renderView];
    self.renderView.translatesAutoresizingMaskIntoConstraints = false;
    NSLayoutConstraint *top = [self.renderView.topAnchor constraintEqualToAnchor:self.renderViewWapper.topAnchor];
    NSLayoutConstraint *bottom = [self.renderView.bottomAnchor constraintEqualToAnchor:self.renderViewWapper.bottomAnchor];
    NSLayoutConstraint *left = [self.renderView.leftAnchor constraintEqualToAnchor:self.renderViewWapper.leftAnchor];
    NSLayoutConstraint *right = [self.renderView.rightAnchor constraintEqualToAnchor:self.renderViewWapper.rightAnchor];
    [NSLayoutConstraint activateConstraints:@[top, bottom, left, right]];
    [self.renderView layoutIfNeeded];
    
    
}

@end
