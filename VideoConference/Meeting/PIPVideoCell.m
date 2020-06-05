//
//  PIPVideoCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/15.
//  Copyright © 2020 agora. All rights reserved.
//

#import "PIPVideoCell.h"
#import "UIImage+Circle.h"
#import "EEWhiteboardTool.h"
#import "EEColorShowView.h"
#import "ScaleView.h"

@interface PIPVideoCell ()<WhiteToolDelegate>

@property (weak, nonatomic) IBOutlet ScaleView *remoteView;
@property (weak, nonatomic) IBOutlet UIView *localView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIView *shareBoardView;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;
@property (weak, nonatomic) IBOutlet UIButton *endBtn;

@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEColorShowView *whiteboardColor;

@property (weak, nonatomic) IBOutlet UIView *stateBg;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *hostImgView;
@property (weak, nonatomic) IBOutlet UIImageView *shareImgView;
@property (weak, nonatomic) IBOutlet UIImageView *audioImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hostWConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareWConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioWConstraint;

@end

@implementation PIPVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIImage *image = [UIImage generateImageWithSize:CGSizeMake(32, 32)];
    image = [UIImage circleImageWithOriginalImage:image];
    self.imgView.image = image;
    
    UIView *boardView = [WhiteManager createWhiteBoardView];
    [self.shareBoardView addSubview:boardView];
    [boardView equalTo:self.shareBoardView];
    self.boardView = boardView;
    
    self.whiteboardTool.backgroundColor = UIColor.clearColor;
    [self.whiteboardTool setDirectionPortrait: NO];
    self.whiteboardTool.delegate = self;
    
    [self.whiteboardColor setSelectColor:^(NSString * _Nullable colorString) {
        NSArray *colorArray = [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        [AgoraRoomManager.shareManager.whiteManager setWhiteStrokeColor:colorArray];
    }];
    
    self.stateBg.hidden = YES;
    self.stateBg.layer.cornerRadius = 11;
    self.stateBg.clipsToBounds = YES;
}

- (void)removeVideoCanvas {
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    [manager removeVideoCanvasWithView:self.localView];
    [manager removeVideoCanvasWithView:self.remoteView];
    [manager removeVideoCanvasWithView:self.shareView];
}

- (void)setUser:(ConfUserModel *)userModel shareBoardModel:(ConfShareBoardUserModel *)boardModel {
    
    [self removeVideoCanvas];
    
    self.shareView.hidden = YES;
    self.shareBoardView.hidden = NO;
    self.remoteView.hidden = YES;
    self.imgView.hidden = YES;
    self.whiteboardTool.hidden = YES;
    self.whiteboardColor.hidden = YES;
    
    // has apply
    if(userModel.grantBoard) {
        self.whiteboardTool.hidden = NO;
        self.applyBtn.hidden = YES;
        self.endBtn.hidden = YES;
    } else {
        self.applyBtn.hidden = NO;
        self.endBtn.hidden = YES;
    }
    
    [self updateWhiteView];
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    if(userModel.enableVideo) {
        self.localView.hidden = NO;
        [manager addVideoCanvasWithUId:userModel.uid inView:self.localView];
    } else {
        self.localView.hidden = YES;
    }
}

- (void)setUser:(ConfUserModel *)userModel shareScreenModel:(ConfShareScreenUserModel *)screenModel {
    [self removeVideoCanvas];

    self.shareView.hidden = NO;
    self.shareBoardView.hidden = YES;
    self.remoteView.hidden = YES;
    self.imgView.hidden = YES;
    
    self.whiteboardTool.hidden = YES;
    self.whiteboardColor.hidden = YES;
    self.applyBtn.hidden = YES;
    self.endBtn.hidden = YES;
    
    [self updateWhiteView];
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    if(userModel.enableVideo) {
        self.localView.hidden = NO;
        [manager addVideoCanvasWithUId:userModel.uid inView:self.localView];
    } else {
        self.localView.hidden = YES;
    }
    
    [manager addVideoCanvasWithUId:screenModel.screenId inView:self.shareView showType:ShowViewTypeFit];
}

- (void)setUser:(ConfUserModel *)userModel remoteUser:(ConfUserModel *)remoteUserModel {
    
    [self removeVideoCanvas];
    
    self.shareView.hidden = YES;
    self.shareBoardView.hidden = YES;
    self.imgView.hidden = YES;
    
    self.whiteboardTool.hidden = YES;
    self.whiteboardColor.hidden = YES;
    self.applyBtn.hidden = YES;
    self.endBtn.hidden = YES;
    
    [self updateWhiteView];
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    if(userModel.enableVideo) {
        self.localView.hidden = NO;
        [manager addVideoCanvasWithUId:userModel.uid inView:self.localView];
    } else {
        self.localView.hidden = YES;
    }
    
    if(remoteUserModel.enableVideo) {
        self.imgView.hidden = YES;
        self.remoteView.hidden = NO;
        [manager addVideoCanvasWithUId:remoteUserModel.uid inView:self.remoteView];
    } else {
        self.imgView.hidden = NO;
        self.remoteView.hidden = YES;
    }
}

- (void)setOneUserModel:(ConfUserModel *)userModel {
    
    [self removeVideoCanvas];
    
    self.shareView.hidden = YES;
    self.localView.hidden = YES;
    
    self.whiteboardTool.hidden = YES;
    self.whiteboardColor.hidden = YES;
    self.applyBtn.hidden = YES;
    self.endBtn.hidden = YES;
    
    [self updateWhiteView];
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    if(userModel.enableVideo) {
        self.imgView.hidden = YES;
        self.remoteView.hidden = NO;
        [manager addVideoCanvasWithUId:userModel.uid inView:self.remoteView];
        //        [manager addVideoCanvasWithUId:userModel.uid inView:self.remoteView.contentView];
    } else {
        self.imgView.hidden = NO;
        self.remoteView.hidden = YES;
    }
}

- (void)updateWhiteView {
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    if(NoNullString(manager.roomModel.createBoardUserId).integerValue == 0){
        self.whiteboardTool.hidden = YES;
        self.applyBtn.hidden = YES;
        return;
    }
    
    BOOL white = NO;
    if(manager.ownModel.role == ConfRoleTypeHost){
        white = YES;
    } else {
        white = manager.ownModel.grantBoard;
    }
    
    self.applyBtn.hidden = white;
    
    WEAK(self);
    WhiteManager *whiteManager = AgoraRoomManager.shareManager.whiteManager;
    [whiteManager setWritable:white completionHandler:^(BOOL isWritable, NSError * _Nullable error) {
        weakself.whiteboardTool.hidden = !isWritable;
    }];
}

- (IBAction)appleBoard:(id)sender {
    
    WEAK(self);
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    [manager p2pActionWithType:EnableSignalTypeGrantBoard actionType:P2PMessageTypeActionApply userId:manager.roomModel.createBoardUserId completeSuccessBlock:^{
        
    } completeFailBlock:^(NSError * _Nonnull error) {
        [weakself showMsgToast:error.localizedDescription];
    }];
}

- (IBAction)endBoard:(id)sender {
}

- (void)showMsgToast:(NSString *)title {
    UIViewController *vc = [VCManager getTopVC];
    if (vc != nil && title != nil && title.length > 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc.view makeToast:title];
        });
    }
}

#pragma mark WhiteToolDelegate
- (void)selectWhiteTool:(ToolType)index {
    
    NSArray<NSString *> *applianceNameArray = @[WhiteApplianceSelector, WhiteAppliancePencil, WhiteApplianceText, WhiteApplianceEraser];
    if(index < applianceNameArray.count) {
        NSString *applianceName = [applianceNameArray objectAtIndex:index];
        if(applianceName != nil) {
            WhiteManager *manager = AgoraRoomManager.shareManager.whiteManager;
            [manager setWhiteApplianceName:applianceName];
        }
    }
    
    BOOL bHidden = self.whiteboardColor.hidden;
    // select color
    if (index == 4) {
        self.whiteboardColor.hidden = !bHidden;
    } else if (!bHidden) {
        self.whiteboardColor.hidden = YES;
    }
}

- (void)updateStateView {
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    if(manager.userListModels.count <= 1) {
        self.stateBg.hidden = YES;
    } else {
        self.stateBg.hidden = NO;
        
        BOOL enableAudio = YES;
        ConfRoleType roleType = ConfRoleTypeHost;
        if(manager.roomModel.shareScreenUsers.count > 0 || manager.roomModel.shareBoardUsers.count > 0) {
            
            NSString *userName = @"";
            NSInteger uid = 0;
            if(manager.roomModel.shareScreenUsers.count > 0) {
                
                for(ConfShareScreenUserModel *model in manager.roomModel.shareScreenUsers) {
                    if([model.userId isEqualToString:NoNullString(manager.roomModel.createBoardUserId)]) {
                        userName = model.userName;
                        roleType = model.role;
                        uid = model.uid;
                        break;
                    }
                }
            } else {
                for(ConfShareBoardUserModel *model in manager.roomModel.shareBoardUsers) {
                    if([model.userId isEqualToString:NoNullString(manager.roomModel.createBoardUserId)]) {
                        userName = model.userName;
                        roleType = model.role;
                        uid = model.uid;
                        break;
                    }
                }
            }
            self.nameLabel.text = userName;
            self.shareImgView.hidden = NO;
            self.shareWConstraint.constant = 17;
            if(roleType == ConfRoleTypeHost){
                self.hostImgView.hidden = NO;
                self.hostWConstraint.constant = 17;
            } else {
                self.hostImgView.hidden = YES;
                self.hostWConstraint.constant = 0;
            }
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", uid];
            NSArray<ConfUserModel *> *filteredHostArray = [manager.userListModels  filteredArrayUsingPredicate:predicate];
            if(filteredHostArray.count > 0){
                enableAudio = filteredHostArray.firstObject.enableAudio;
            }
        } else {
            self.shareImgView.hidden = YES;
            self.shareWConstraint.constant = 0;
            ConfUserModel *model = manager.userListModels[1];
            roleType = model.role;
            self.nameLabel.text = model.userName;
            enableAudio = model.enableAudio;
        }
        
        if(roleType == ConfRoleTypeHost){
            self.hostImgView.hidden = NO;
            self.hostWConstraint.constant = 17;
        } else {
            self.hostImgView.hidden = YES;
            self.hostWConstraint.constant = 0;
        }
        self.audioImgView.image = [UIImage imageNamed:enableAudio ? @"state-unmute" : @"state-mute"];
    }
}

@end
