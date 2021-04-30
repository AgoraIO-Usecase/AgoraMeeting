//
//  SetSwitchCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/10.
//  Copyright © 2020 agora. All rights reserved.
//

#import "SetSwitchCell.h"

@implementation SetSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (IBAction)onSwitchBtn:(id)sender {
    if([self.delegate respondsToSelector:@selector(setSwitchCellSwitchValueDidChange:AtIndexPath:)]) {
        [self.delegate setSwitchCellSwitchValueDidChange:self.switchBtn.on AtIndexPath:_indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)idf {
    return @"SetSwitchCell";
}

+ (NSString *)nibName {
    return [SetSwitchCell idf];
}


@end
