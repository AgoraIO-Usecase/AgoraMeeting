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

        NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time * 0.001];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timeString = [formatter stringFromDate:date];
        self.time.text = timeString;
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
