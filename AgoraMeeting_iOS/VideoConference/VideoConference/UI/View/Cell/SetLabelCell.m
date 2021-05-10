//
//  SetLabelCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/10.
//  Copyright © 2020 agora. All rights reserved.
//

#import "SetLabelCell.h"

@implementation SetLabelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)idf {
    return @"SetLabelCell";
}

+ (NSString *)nibName {
    return [SetLabelCell idf];
}

@end
