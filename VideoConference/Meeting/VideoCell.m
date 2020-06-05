//
//  VideoCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/15.
//  Copyright © 2020 agora. All rights reserved.
//

#import "VideoCell.h"
#import "UIImage+Circle.h"

@interface VideoCell ()

@property (weak, nonatomic) IBOutlet UIView *renderView;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;

@property (weak, nonatomic) IBOutlet UIImageView *hostView;
@property (weak, nonatomic) IBOutlet UIImageView *shareView;
@property (weak, nonatomic) IBOutlet UIImageView *audioView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hostWConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareWConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioWConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareLConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioLConstraint;
@end


@implementation VideoCell
- (void)awakeFromNib {
    [super awakeFromNib];
    UIImage *image = [UIImage generateImageWithSize:CGSizeMake(32, 32)];
    image = [UIImage circleImageWithOriginalImage:image];
    self.headImgView.image = image;
}

- (void)setShareBoardModel:(ConfShareBoardUserModel *)userModel {
    
}

- (void)setShareScreenModel:(ConfShareScreenUserModel *)userModel {
    
}

- (void)setUserModel:(ConfUserModel * _Nullable)userModel {
    if(userModel == nil){
        self.hidden = YES;
        return;
    }
     self.hidden = NO;
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    
    if (userModel.enableVideo) {
        [manager addVideoCanvasWithUId:userModel.uid inView:self.renderView];
        self.renderView.hidden = NO;
        self.headImgView.hidden = YES;
    } else {
        [manager removeVideoCanvasWithView:self.renderView];
        self.headImgView.hidden = NO;
        self.renderView.hidden = YES;
    }
    
    self.nameLabel.text = userModel.userName;
    if(userModel.role == ConfRoleTypeHost) {
        self.hostView.hidden = NO;
        self.hostWConstraint.constant = 17;
        self.shareLConstraint.constant = 3;
    } else {
        self.hostView.hidden = YES;
        self.hostWConstraint.constant = 0;
        self.shareLConstraint.constant = 0;
    }
    
    if(userModel.grantBoard || userModel.grantScreen) {
        self.shareView.hidden = NO;
        self.shareWConstraint.constant = 17;
        self.audioLConstraint.constant = 3;
    } else {
        self.shareView.hidden = YES;
        self.shareWConstraint.constant = 0;
        self.shareLConstraint.constant = 0;
        self.audioLConstraint.constant = 0;
    }
    
    self.audioView.hidden = NO;
    if(userModel.enableAudio) {
        self.audioView.image = [UIImage imageNamed:@"state-unmute"];
    } else {
        self.audioView.image = [UIImage imageNamed:@"state-mute"];
    }
}
@end
