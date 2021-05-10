//
//  SetImageCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/10.
//  Copyright © 2020 agora. All rights reserved.
//

#import "SetImageCell.h"

@implementation SetImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.imgView.layer.cornerRadius = 32/2;
    self.imgView.layer.masksToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

+ (NSString *)idf {
    return @"SetImageCell";
}

+ (NSString *)nibName {
    return [SetImageCell idf];
}

@end
