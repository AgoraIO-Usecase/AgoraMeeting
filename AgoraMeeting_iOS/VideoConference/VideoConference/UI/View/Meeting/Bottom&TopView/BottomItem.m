//
//  BottomItem.m
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import "BottomItem.h"
#import "UIView+EEBadge.h"



@implementation BottomItemInfo

@end

@interface BottomItem()

@property (strong, nonatomic) IBOutlet BottomItem *item;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *circlrView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic, assign) NSInteger timeCount;
@property (nonatomic, strong) BottomItemInfo *info;
@property (nonatomic, assign) BottomItemState state;
@property (nonatomic, assign) NSInteger redDotCount;
@property (weak, nonatomic) IBOutlet UIButton *button;


@end

@implementation BottomItem

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.item];
        [self.item equalTo:self];
        self.imageView.clipsToBounds = NO;
        [self.circlrView setBackgroundColor:UIColor.clearColor];
        self.circlrView.layer.masksToBounds = true;
        self.circlrView.layer.cornerRadius = 12;
        self.circlrView.layer.borderWidth = 1;
        self.circlrView.layer.borderColor = UIColor.whiteColor.CGColor;
    }
    return self;
}

- (void)configInfo:(BottomItemInfo *)info {
    self.info = info;
    self.titleLabel.text = info.title;
    [self.imageView setHidden:false];
    [self.circlrView setHidden:true];
}

- (void)configState:(BottomItemState)state timeCount:(NSInteger)timeCount {
    self.timeCount = timeCount;
    self.state = state;
    switch (state) {
        case BottomItemStateInactive:
            self.imageView.image = [UIImage imageNamed:_info.inActiveImageName];
            self.titleLabel.textColor = _info.inActiveTextColor;
            [self.imageView setHidden:false];
            [self.circlrView setHidden:true];
            [self.numberLabel setHidden:true];
            [self hidenBadge];
            break;
        case BottomItemStateActive:
            self.imageView.image = [UIImage imageNamed:_info.activeImageName];
            self.titleLabel.textColor = _info.activeTextColor;
            [self.imageView setHidden:false];
            [self.circlrView setHidden:true];
            [self.numberLabel setHidden:true];
            [self hidenBadge];
            break;
        case BottomItemStateRedDot:
            [self.imageView showBadgeWithRightMagin:-8 topMagin:0];
            [self setBadgeCount:_redDotCount];
            self.imageView.image = [UIImage imageNamed:_info.activeImageName];
            [self.imageView setHidden:false];
            [self.circlrView setHidden:true];
            [self.numberLabel setHidden:true];
            break;
        case BottomItemStateTime:
            self.numberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_timeCount];
            self.titleLabel.textColor = _info.activeTextColor;
            [self.numberLabel setHidden:false];
            [self.imageView setHidden:true];
            [self.circlrView setHidden:false];
            [self hidenBadge];
            break;
        default:
            break;
    }
    
}

- (BottomItemState)getState {
    return  _state;
}

- (void)setButtonEnable:(BOOL)enable {
    [self.button setEnabled:enable];
}

- (void)setRedDoc:(NSInteger)count {
    _redDotCount = count;
    [self showBadgeWithTopMagin:0];
    [self setBadgeCount:count];
}


- (IBAction)onSelectBar:(BottomItem *)sender {
    if(self.state == BottomItemStateTime) { return; }
    if(self.block != nil){
        self.block();
    }
}

@end
