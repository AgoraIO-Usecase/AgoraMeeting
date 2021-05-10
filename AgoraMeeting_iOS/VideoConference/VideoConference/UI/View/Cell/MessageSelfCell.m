//
//  MessageSelfCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/13.
//  Copyright © 2020 agora. All rights reserved.
//

#import "MessageSelfCell.h"

@interface MessageSelfCell ()

@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *msg;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBgWConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatedView;
@property (weak, nonatomic) IBOutlet UIButton *failButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgTextConstraint;

@end

@implementation MessageSelfCell

- (void)awakeFromNib {
    [super awakeFromNib];

    CGFloat top = self.bgImgView.image.size.height / 2.0;
    CGFloat left = self.bgImgView.image.size.width / 2.0;
    CGFloat bottom = self.bgImgView.image.size.height / 2.0;
    CGFloat right = self.bgImgView.image.size.width / 2.0;
    self.bgImgView.image = [self.bgImgView.image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right)resizingMode:UIImageResizingModeStretch];
}

- (void)updateWithTime:(NSInteger)time message:(NSString *)msg {
    self.msg.text = msg;
    
    CGFloat maxWidth = kScreenWidth - 9 - 54 - 24;
    CGSize msgSize = [self.msg sizeThatFits:CGSizeMake(maxWidth, NSIntegerMax)];
    self.textBgWConstraint.constant = msgSize.width + 24;
    
    if(time == 0){
        self.time.hidden = YES;
        self.timeHeightConstraint.constant = 0;
    } else {
        self.time.hidden = NO;
        self.timeHeightConstraint.constant = 17;
        NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"hh:mm a"];
        NSString *timeString = [formatter stringFromDate:date];
        self.time.text = timeString;
    }

}

- (void)updateStatus:(MessageSelfCellStatus)status {
    switch (status) {
        case MessageSelfCellStatusSending:
            [self.indicatedView setHidden:false];
            [self.indicatedView startAnimating];
            [self.failButton setHidden:true];
            break;
        case MessageSelfCellStatusSuccess:
            [self.indicatedView setHidden:true];
            [self.failButton setHidden:true];
            break;
        case MessageSelfCellStatusFail:
            [self.indicatedView setHidden:true];
            [self.failButton setHidden:false];
            break;
        default:
            break;
    }
}

- (void)updateTimeShow:(BOOL)show {
    [self.time setHidden:!show];
    _msgTextConstraint.constant = show ? 35 : 10;
    [self.contentView layoutIfNeeded];
}

- (IBAction)buttonTap:(UIButton *)sender {
    if([_delegate respondsToSelector:@selector(messageSelfCelldidTapFailButton:)]) {
        [_delegate messageSelfCelldidTapFailButton:self.indexPath];
    }
}


@end
