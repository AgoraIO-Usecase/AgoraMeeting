//
//  SetTextFieldCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/10.
//  Copyright © 2020 agora. All rights reserved.
//

#import "SetTextFieldCell.h"

@implementation SetTextFieldCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)idf {
    return @"SetTextFieldCell";
}

+ (NSString *)nibName {
    return [SetTextFieldCell idf];
}

@end
