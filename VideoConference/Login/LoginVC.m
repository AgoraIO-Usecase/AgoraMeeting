//
//  LoginVC.m
//  VideoConference
//
//  Created by SRS on 2020/5/9.
//  Copyright © 2020 agora. All rights reserved.
//

#import "LoginVC.h"
#import "VCManager.h"
#import "SetVC.h"
#import "UserDefaults.h"
#import "MeetingVC.h"
#import "AgoraRoomManager.h"

@interface LoginVC ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *textFieldBgView;
@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *micSwitch;
@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (weak, nonatomic) IBOutlet UITextField *roomName;
@property (weak, nonatomic) IBOutlet UITextField *roomPsd;
@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UIImageView *signalImgView;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.cameraSwitch.on = [UserDefaults getOpenCamera];
    self.micSwitch.on = [UserDefaults getOpenMic];
    self.userName.text = [UserDefaults getUserName];

    WEAK(self);
    [AgoraRoomManager.shareManager.conferenceManager netWorkProbeTestCompleteBlock:^(NetworkGrade grade) {
        
        NSString *imgName = @"signal_unknown";
        switch (grade) {
            case NetworkGradeLow:
                imgName = @"signal_bad";
                break;
            case NetworkGradeMiddle:
                imgName = @"signal_poor";
                break;
            case NetworkGradeHigh:
                imgName = @"signal_good";
                break;
            default:
                break;
        }
        weakself.signalImgView.image = [UIImage imageNamed:imgName];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UserDefaults setUserName:self.userName.text];
}

- (void)initView {
    
    self.textFieldBgView.layer.borderWidth = 1;
    self.textFieldBgView.layer.borderColor = [UIColor colorWithHexString:@"E9EFF4"].CGColor;
    self.textFieldBgView.layer.cornerRadius = 5;
}

- (IBAction)onClickSet:(id)sender {
    
    [self.view endEditing:YES];
    self.tipView.hidden = YES;
    
    SetVC *vc = [[SetVC alloc] initWithNibName:@"SetVC" bundle:nil];
    [VCManager pushToVC:vc];
}

- (IBAction)onSwitchCamera:(id)sender {
    [UserDefaults setOpenCamera:self.cameraSwitch.on];
    self.tipView.hidden = YES;
}

- (IBAction)onSwitchMic:(id)sender {
    [UserDefaults setOpenMic:self.micSwitch.on];
    self.tipView.hidden = YES;
}

- (IBAction)onClickJoin:(UIButton *)sender {
    [self.view endEditing:YES];
    self.tipView.hidden = YES;
    
//    self.roomName.text = @"1111";
//    self.roomPsd.text = @"123";
    
    NSString *userName = self.userName.text;
    NSString *roomPsd = self.roomPsd.text;
    NSString *roomName = self.roomName.text;
    
    if (userName.length <= 0 || roomName.length <= 0) {
        [self showToast:NSLocalizedString(@"UserNameVerifyEmptyText", nil)];
        return;
    }
    NSInteger strlength = [self checkFieldText:roomName];
    if(strlength < 3){
        [self showToast:NSLocalizedString(@"RoomNameMinVerifyText", nil)];
        return;
    }
    if(strlength > 50){
        [self showToast:NSLocalizedString(@"RoomNameMaxVerifyText", nil)];
        return;
    }
    strlength = [self checkFieldText:userName];
    if(strlength < 3){
        [self showToast:NSLocalizedString(@"UserNameMinVerifyText", nil)];
        return;
    }
    if(strlength > 20){
        [self showToast:NSLocalizedString(@"UserNameMaxVerifyText", nil)];
        return;
    }
    strlength = [self checkFieldText:roomPsd];
    if(strlength > 20){
        [self showToast:NSLocalizedString(@"PsdMaxVerifyText", nil)];
        return;
    }
    
    ConferenceEntryParams *params = [ConferenceEntryParams new];
    params.userName = userName;
    params.userUuid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    params.roomName = roomName;
    params.roomUuid = roomName;
    params.password = roomPsd;
    params.enableVideo = self.cameraSwitch.on;
    params.enableAudio = self.micSwitch.on;
    params.avatar = @"";
    
    [self setLoadingVisible:YES];
    WEAK(self);
    [AgoraRoomManager.shareManager.conferenceManager entryConfRoomWithParams:params successBolck:^{
        
        [UserDefaults setUserName: userName];
        [UserDefaults setOpenCamera: params.enableVideo];
        [UserDefaults setOpenMic: params.enableAudio];
        
        [weakself setLoadingVisible:NO];
        MeetingVC *vc = [[MeetingVC alloc] initWithNibName:@"MeetingVC" bundle:nil];
        [VCManager pushToVC:vc];
        
    } failBlock:^(NSError * _Nonnull error) {
        [weakself setLoadingVisible:NO];
        [weakself showToast:error.localizedDescription];
    }];
}

- (NSInteger)checkFieldText:(NSString *)text {
    int strlength = 0;
    char *p = (char *)[text cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}
- (void)setLoadingVisible:(BOOL)show {
    if(show) {
        [self.activityIndicator startAnimating];
        [self.joinButton setEnabled:NO];
    } else {
        [self.activityIndicator stopAnimating];
        [self.joinButton setEnabled:YES];
    }
}

- (IBAction)onClickTip:(id)sender {
    BOOL hidden = self.tipView.hidden;
    self.tipView.hidden = !hidden;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.tipView.hidden = YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.tipView.hidden = YES;
    return YES;
}

@end
