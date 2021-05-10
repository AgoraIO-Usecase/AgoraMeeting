//
//  MessageCell.m
//  VideoConference
//
//  Created by ZYP on 2021/1/5.
//  Copyright © 2021 agora. All rights reserved.
//

#import "MeetingMessageCell.h"
#import "UIColor+AppColor.h"
#import "MeetingMessageModel.h"

@interface MeetingMessageCell () {
    NSLayoutConstraint *_bgViewHeightConstraint;
    NSLayoutConstraint *_bgViewTrailingConstraint;
    
}

@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UILabel *infoLabel;
@property (nonatomic, strong)UIButton *button;
@property (nonatomic, strong)UIView *bgView;
@property (nonatomic, strong)MeetingMessageModel *model;
@property (nonatomic, strong)NSLayoutConstraint *buttonWidthConstraint;

@end

static const CGFloat bgViewHeightSmall = 24;
static const CGFloat bgViewHeightBig = 44;

@implementation MeetingMessageCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        _nameLabel = [UILabel new];
        _infoLabel = [UILabel new];
        _button = [UIButton new];
        _bgView = [UIView new];
        [self layout];
    }
    return self;
}

- (void)layout {
    self.backgroundColor = UIColor.clearColor;
    
    UIFont *font = [UIFont systemFontOfSize:9];
    [_nameLabel setFont:font];
    [_infoLabel setFont:font];
    [_nameLabel setTextColor:UIColor.whiteColor];
    [_infoLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.5]];
    _infoLabel.numberOfLines = 0;
    [_button setBackgroundColor:UIColor.themColor];
    [_button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_button setTitleColor:UIColor.whiteColor forState:UIControlStateDisabled];
    _button.layer.masksToBounds = true;
    _button.layer.cornerRadius = 2;
    [_button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [_button addTarget:self action:@selector(buttonTap) forControlEvents:UIControlEventTouchUpInside];
    
    [_bgView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.6]];
    _bgView.layer.masksToBounds = true;
    _bgView.layer.cornerRadius = 2;
    
    [self.contentView addSubview:_bgView];
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_infoLabel];
    [self.contentView addSubview:_button];
    [self.contentView addSubview:_nameLabel];
    
    _nameLabel.translatesAutoresizingMaskIntoConstraints = false;
    _infoLabel.translatesAutoresizingMaskIntoConstraints = false;
    _button.translatesAutoresizingMaskIntoConstraints = false;
    _bgView.translatesAutoresizingMaskIntoConstraints = false;
    
    [NSLayoutConstraint activateConstraints:@[
        [_nameLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5],
        [_nameLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_nameLabel.widthAnchor constraintLessThanOrEqualToConstant:240]
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [_infoLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.trailingAnchor],
        [_infoLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
    
    _buttonWidthConstraint = [_button.widthAnchor constraintEqualToConstant:80];
    [NSLayoutConstraint activateConstraints:@[
        [_button.heightAnchor constraintEqualToConstant:24],
        [_button.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_button.leadingAnchor constraintEqualToAnchor:_infoLabel.trailingAnchor constant:5],
        _buttonWidthConstraint,
    ]];
    
    
    _bgViewHeightConstraint =  [_bgView.heightAnchor constraintEqualToConstant:bgViewHeightBig];
    _bgViewTrailingConstraint = [_bgView.trailingAnchor constraintEqualToAnchor:_button.trailingAnchor constant:5];
    [NSLayoutConstraint activateConstraints:@[
        [_bgView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        _bgViewTrailingConstraint,
        _bgViewHeightConstraint,
        [_bgView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
    
    self.contentView.transform = CGAffineTransformMakeScale(1, -1);
}

- (void)setModel:(MeetingMessageModel *)model {
    _model = model;
    _nameLabel.text = model.name;
    _infoLabel.text = model.info;
    [_button setHidden:!model.showButton];
    NSString *buttonTitle = model.buttonTitle;
    model.buttonEnable ? [_button setBackgroundColor:UIColor.themColor] : [_button setBackgroundColor: UIColor.grayColor];
    if (model.remianCount > 0) {
        buttonTitle = [NSString stringWithFormat:@"%@（%ld）", buttonTitle, model.remianCount];
        [_button setTitle:buttonTitle forState:UIControlStateNormal];
    }
    else {
        [_button setTitle:buttonTitle forState:UIControlStateNormal];
        [_button setTitle:buttonTitle forState:UIControlStateDisabled];
        [_button setEnabled:model.buttonEnable];
    }
    if (_button.isHidden) {
        [_button setTitle:@"" forState:UIControlStateNormal];
    }
    if (model.showButton) {
        _bgViewHeightConstraint.constant = bgViewHeightBig;
        CGFloat maxWidth = kScreenWidth * 0.5;
        CGFloat width = [self sizeWithString: buttonTitle Font:_button.titleLabel.font maxSize: CGSizeMake(maxWidth, NSIntegerMax)].width + 15;
        _buttonWidthConstraint.constant = width;
    }
    else {
        _bgViewHeightConstraint.constant = bgViewHeightSmall;
        _buttonWidthConstraint.constant = 0.1;
    }
}

- (void)setIndex:(NSInteger)index {
    if (index >= 2) {
        self.nameLabel.alpha = 0.3;
        self.infoLabel.alpha = 0.3;
        self.button.alpha = 0.3;
        self.bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    }
    else {
        self.nameLabel.alpha = 1;
        self.infoLabel.alpha = 1;
        self.button.alpha = 1;
        self.bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
}

- (void)buttonTap {
    if ([_delegate respondsToSelector:@selector(meetingMessageCell:didTapButton:)]) {
        [_delegate meetingMessageCell:self didTapButton:_model];
    }
}

- (CGSize)sizeWithString:(NSString *)string Font:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

@end
