//
//  UserCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/13.
//  Copyright © 2020 agora. All rights reserved.
//

#import "UserCell.h"
#import "UIImage+Circle.h"

@interface UserCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *hostImgView;
@property (weak, nonatomic) IBOutlet UIImageView *shareImgView;
@property (weak, nonatomic) IBOutlet UIImageView *videoImgView;
@property (weak, nonatomic) IBOutlet UIImageView *audioImgView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareWConstraint;
@end

@implementation UserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    UIImage *image = [UIImage generateImageWithSize:CGSizeMake(24, 24)];
    image = [UIImage circleImageWithOriginalImage:image];
    self.imgView.image = image;
}

- (void)updateViewWithModel:(ConfUserModel *)userModel {
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    if(userModel.uid == manager.ownModel.uid) {
        if(userModel.role == ConfRoleTypeHost) {
            self.nameLabel.text = [NSString stringWithFormat:@"%@（我、主持人）", userModel.userName];
        } else {
            self.nameLabel.text = [NSString stringWithFormat:@"%@（我）", userModel.userName];
        }
    } else if(userModel.role == ConfRoleTypeHost) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@（主持人）", userModel.userName];
    } else {
        self.nameLabel.text = userModel.userName;
    }
    
    if(userModel.role == ConfRoleTypeHost) {
        self.hostImgView.hidden = NO;
    } else {
        self.hostImgView.hidden = YES;
    }
    
    BOOL share = NO;
    if(userModel.grantScreen){
        share = YES;
    } else if(userModel.grantBoard) {
        if([NoNullString(manager.roomModel.createBoardUserId) isEqualToString:userModel.userId]) {
            share = YES;
        }
    }

    if(share) {
        self.shareImgView.hidden = NO;
        self.shareWConstraint.constant = 24;
    } else {
        self.shareImgView.hidden = YES;
        self.shareWConstraint.constant = 0;
    }
    
    self.audioImgView.image = userModel.enableAudio ?
    [UIImage imageNamed:@"member-audio4"] : [UIImage imageNamed:@"member-audio0"];
    
    self.videoImgView.image = userModel.enableVideo ?
    [UIImage imageNamed:@"member-video1"] : [UIImage imageNamed:@"member-video0"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
