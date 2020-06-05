//
//  ShareLinkView.m
//  VideoConference
//
//  Created by SRS on 2020/5/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ShareLinkView.h"
#import "AgoraRoomManager.h"

#define ITUNES_URL @"https://itunes.apple.com/cn/app/id1515428313"

@interface ShareLinkView()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *animateView;
@property (weak, nonatomic) IBOutlet UILabel *meetName;
@property (weak, nonatomic) IBOutlet UILabel *invitationName;
@property (weak, nonatomic) IBOutlet UILabel *psd;
@property (weak, nonatomic) IBOutlet UILabel *link;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *animateBottomConstraint;
@end

@implementation ShareLinkView

+ (instancetype)createViewWithXib {
    
    ShareLinkView *vv = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;
    vv.backgroundColor = UIColor.clearColor;
    
    [vv initView];
    return vv;
}

- (void)initView {
    UITapGestureRecognizer *tapRecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tapRecognize.numberOfTapsRequired = 1;
    tapRecognize.delegate = self;
    [self.bgView addGestureRecognizer:tapRecognize];
    
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    
    self.meetName.text = [NSString stringWithFormat:@"会议名：%@", manager.roomModel.roomName];
    self.invitationName.text = [NSString stringWithFormat:@"邀请人：%@", manager.ownModel.userName];
    self.psd.text = [NSString stringWithFormat:@"会议密码：%@", manager.roomModel.password];
    self.link.text = ITUNES_URL;
}

#pragma UIGestureRecognizer Handles
-(void) handleTap:(UITapGestureRecognizer *)recognizer {
    [self onCancelBtnClick:nil];
}

- (void)showShareLinkViewInView:(UIView *)inView {
    [self removeFromSuperview];
//    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [inView addSubview:self];
    [self equalTo:inView];
    
    self.bgView.hidden = NO;

//    [self.animateView layoutIfNeeded];
//    [UIView animateWithDuration:0.35 delay:5 usingSpringWithDamping:0.8 initialSpringVelocity:20 options:UIViewAnimationOptionCurveLinear animations:^{
//        self.animateBottomConstraint.constant = 0;
//        [self.animateView layoutIfNeeded];
//    } completion:^(BOOL finished) {
//
//    }];
}

- (void)hiddenShareLinkView {
    self.animateBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.35 animations:^{
        self.animateBottomConstraint.constant = -379;
        [self.animateView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.bgView.hidden = YES;
        [self removeFromSuperview];
    }];
}

- (IBAction)onCopyBtnClick:(id)sender {

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    NSString *webLink = @"web下载链接：https://solutions.agora.io/meeting/web";
    NSString *androidLink = @"Android下载链接：https://download.agora.io/demo/release/app-AgoraMeeting-release.apk";
    NSString *iOSLink = [NSString stringWithFormat:@"iOS下载链接：%@", self.link.text];
    
    NSString *str = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@", self.meetName.text, self.psd.text, self.invitationName.text, webLink, androidLink, iOSLink];
    pasteboard.string = str;
    
    [self hiddenShareLinkView];
    
    // show toast
    [self showMsgToast:@"复制成功"];
}

- (IBAction)onCancelBtnClick:(id)sender {
    [self hiddenShareLinkView];
}

- (void)showMsgToast:(NSString *)title {
    UIViewController *vc = [VCManager getTopVC];
    if (vc != nil && title != nil && title.length > 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc.view makeToast:title];
        });
    }
}

@end
