//
//  SetArrowCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/11.
//  Copyright © 2020 agora. All rights reserved.
//

#import "SetArrowCell.h"

@implementation SetArrowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)idf {
    return @"SetArrowCell";
}

+ (NSString *)nibName {
    return [SetArrowCell idf];
}

@end
