//
//  SetImageCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/10.
//  Copyright © 2020 agora. All rights reserved.
//

#import "SetImageCell.h"
#import "UIImage+Circle.h"

@implementation SetImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImage *image = [UIImage generateImageWithSize:CGSizeMake(32, 32)];
    image = [UIImage circleImageWithOriginalImage:image];
    self.imgView.image = image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
