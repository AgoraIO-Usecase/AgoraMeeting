//
//  AudioCell.m
//  VideoConference
//
//  Created by ZYP on 2021/1/5.
//  Copyright © 2021 agora. All rights reserved.
//

#import "AudioCell.h"

@interface AudioCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *voiceImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageWidthConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageHeightConstraints;

@end

@implementation AudioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled = false;
    [self.headImageView.layer masksToBounds];
    if (UIScreen.mainScreen.bounds.size.width <= 375) {
        _headImageWidthConstraints.constant = 60;
        _headImageHeightConstraints.constant = 60;
        [self.headImageView.layer setCornerRadius:60/2];
    }
    else {
        _headImageWidthConstraints.constant = 72;
        _headImageHeightConstraints.constant = 72;
        [self.headImageView.layer setCornerRadius:72/2];
    }
}

+ (instancetype)instanceFromNib
{
    NSString *className = NSStringFromClass(AudioCell.class);
    return [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil].firstObject;
}

- (void)setImageName:(NSString *)imageName
                name:(NSString *)name
         audioEnable:(BOOL)audioEnable {
    _headImageView.image = [UIImage imageNamed:imageName];
    _titleLabel.text = name;
    _voiceImageView.image = [UIImage imageNamed:audioEnable ? @"state-unmute" : @"state-mute"];
}

@end
