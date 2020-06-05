//
//  SetVC.m
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import "SetVC.h"
#import "SetSwitchCell.h"
#import "SetLabelCell.h"
#import "SetCenterTextCell.h"
#import "SetImageCell.h"
#import "SetTextFieldCell.h"
#import "CommonNavigation.h"
#import "UserDefaults.h"
#import "AgoraRoomManager.h"
#import "ShareLinkView.h"

@interface SetVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CommonNavigation *nav;

@property (weak, nonatomic) SetTextFieldCell *nameCell;
@property (weak, nonatomic) SetSwitchCell *videoCell;
@property (weak, nonatomic) SetSwitchCell *audioCell;
@property (weak, nonatomic) SetCenterTextCell *logCell;

@property (weak, nonatomic) SetSwitchCell *muteCell;
@property (weak, nonatomic) SetSwitchCell *allowUmmuteCell;

@property (nonatomic, assign) BOOL isUploading;

@property (nonatomic, assign) MuteAllAudioState currentState;

@end

@implementation SetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.isMemberSet) {
        self.nav.title.text = @"成员设置";
    } else {
        self.nav.title.text = @"设置";
        WEAK(self);
        self.nav.backBlock = ^(){
            [UserDefaults setUserName:weakself.nameCell.textField.text];
            [VCManager popTopView];
        };
    }
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    self.currentState = manager.roomModel.muteAllAudio;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SetSwitchCell" bundle:nil] forCellReuseIdentifier:@"SetSwitchCell"];
    if(!self.isMemberSet) {
        [self.tableView registerNib:[UINib nibWithNibName:@"SetLabelCell" bundle:nil] forCellReuseIdentifier:@"SetLabelCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"SetCenterTextCell" bundle:nil] forCellReuseIdentifier:@"SetCenterTextCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"SetImageCell" bundle:nil] forCellReuseIdentifier:@"SetImageCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"SetTextFieldCell" bundle:nil] forCellReuseIdentifier:@"SetTextFieldCell"];
    }
    
    [self addNotification];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:NOTICENAME_LOCAL_MEDIA_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:NOTICENAME_ROOM_INFO_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:NOTICENAME_RECONNECT_CHANGED object:nil];
}

- (void)updateView {
    [self.tableView reloadData];
}

#pragma mark UITableViewDelegate, UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if(self.isMemberSet) {
        return [self roomMediaCell:indexPath.row];
    }
    
    if(self.inMeeting) {
        if(indexPath.section == 0){
            
            ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
            
            SetLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SetLabelCell"];
            cell.tipText.text = indexPath.row == 0 ? @"房间名" : @"密码";
            cell.valueText.text = indexPath.row == 0 ? manager.roomModel.roomName : manager.roomModel.password;
            return cell;
        } else if(indexPath.section == 1){
            return [self userInfoCell:indexPath.row];
        } else if(indexPath.section == 2){
            return [self userMediaCell:indexPath.row];
        } else if(indexPath.section == 3){
            return [self invitationCell:indexPath.row];
        } else {
            return [self updloadCell:indexPath.row];
        }
    } else {
        if(indexPath.section == 0){
            UITableViewCell *cell = [self userInfoCell:indexPath.row];
            cell.selectionStyle = NO;
            return cell;
        } else if(indexPath.section == 1){
            return [self userMediaCell:indexPath.row];
        } else {
            return [self updloadCell:indexPath.row];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.inMeeting) {
        if(indexPath.section == 3) {
            // invitation
            ShareLinkView *vv = [ShareLinkView createViewWithXib];
            [vv showShareLinkViewInView:self.view];
            
        } else if(indexPath.section == 4) {
            // upload log
            [self uploadLog];
        }
    } else {
        if(indexPath.section == 2) {
            [self uploadLog];
        }
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.isMemberSet) {
        if(self.currentState == MuteAllAudioStateUnmute) {
            return 1;
        }
        return 2;
    }
    
    if(self.inMeeting) {
        if(section == 0){
            return 2;
        } else if(section == 1){
            return 2;
        } else if(section == 2){
            return 3;
        }
        return 1;
    } else {
        if(section == 0){
            return 2;
        } else if(section == 1){
            return 3;
        }
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(self.isMemberSet) {
        return 1;
    }
    
    if(self.inMeeting) {
        return 5;
    }
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark generate cell
- (UITableViewCell *)userInfoCell:(NSInteger)row {
    if(row == 0){
        SetImageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SetImageCell"];
        return cell;
    } else {
        SetTextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SetTextFieldCell"];
        cell.tipText.text = @"姓名";
        cell.textField.text = [UserDefaults getUserName];
        if(self.inMeeting) {
            cell.textField.enabled = NO;
        } else {
            cell.textField.enabled = YES;
        }
        self.nameCell = cell;
        return cell;
    }
}

- (UITableViewCell *)userMediaCell:(NSInteger)row {
    SetSwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SetSwitchCell"];
    
    WEAK(self);
    if(row == 0){
        cell.tipText.text = @"摄像头";
        if(self.inMeeting) {
            ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
            cell.switchBtn.on = manager.ownModel.enableVideo;
        } else {
            cell.switchBtn.on = [UserDefaults getOpenCamera];
        }
        cell.block = ^(BOOL on) {
            [weakself checkUpdateUserWithType:EnableSignalTypeVideo value:on];
        };
        self.videoCell = cell;
        
    } else if(row == 1) {
        cell.tipText.text = @"麦克风";
        if(self.inMeeting) {
            ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
            cell.switchBtn.on = manager.ownModel.enableAudio;
        } else {
            cell.switchBtn.on = [UserDefaults getOpenMic];
        }
        cell.block = ^(BOOL on) {
            [weakself checkUpdateUserWithType:EnableSignalTypeAudio value:on];
        };
        self.audioCell = cell;
        
    } else if(row == 2) {
        cell.tipText.text = @"美颜（敬请期待）";
        cell.switchBtn.on = NO;
        cell.switchBtn.enabled = NO;
    }
    return cell;
}

- (UITableViewCell *)roomMediaCell:(NSInteger)row {
    SetSwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SetSwitchCell"];
    
    WEAK(self);
    
    if (row == 0) {
        cell.tipText.text = @"全体静音";
        cell.switchBtn.on = self.currentState != MuteAllAudioStateUnmute ? YES : NO;
        cell.block = ^(BOOL on) {
            [weakself updateRoomWithIndex:0 value:on];
        };
        self.muteCell = cell;
    } else if(row == 1) {
        cell.tipText.text = @"允许成员自我解除静音";
        cell.switchBtn.on = self.currentState == MuteAllAudioStateAllowUnmute ? YES : NO;
        cell.block = ^(BOOL on) {
            [weakself updateRoomWithIndex:1 value:on];
        };
        self.allowUmmuteCell = cell;
    }
    return cell;
}

- (UITableViewCell *)invitationCell:(NSInteger)row {
    SetCenterTextCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SetCenterTextCell"];
    cell.tipText.text = @"邀请他人入会";
    cell.tipText.textColor = [UIColor colorWithHexString:@"268CFF"];
    cell.loading.hidden = YES;
    return cell;
}

- (UITableViewCell *)updloadCell:(NSInteger)row {
    SetCenterTextCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SetCenterTextCell"];
    cell.tipText.text = @"上传日志";
    cell.tipText.textColor = [UIColor colorWithHexString:@"323C47"];
    cell.loading.hidden = YES;
    self.logCell = cell;
    return cell;
}

#pragma mark upload log
- (void)uploadLog {
    if(self.isUploading) {
        return;
    }
    
    self.logCell.loading.hidden = NO;
    [self.logCell.loading startAnimating];
    self.logCell.tipText.hidden = YES;
    self.isUploading = YES;
    
    // upload log
    WEAK(self);
    [AgoraRoomManager.shareManager.conferenceManager uploadLogWithSuccessBlock:^(NSString * _Nonnull uploadSerialNumber) {
        
        weakself.logCell.loading.hidden = YES;
        [weakself.logCell.loading stopAnimating];
        weakself.logCell.tipText.hidden = NO;
        weakself.isUploading = NO;
        
        [AlertViewUtil showAlertWithController:[VCManager getTopVC] title:NSLocalizedString(@"UploadLogSuccessText", nil) message:uploadSerialNumber cancelText:nil sureText:NSLocalizedString(@"OKText", nil) cancelHandler:nil sureHandler:nil];
        
    } failBlock:^(NSError * _Nonnull error) {
        weakself.logCell.loading.hidden = YES;
        [weakself.logCell.loading stopAnimating];
        weakself.logCell.tipText.hidden = NO;
        weakself.isUploading = NO;
        [weakself showToast:error.localizedDescription];
    }];
}

- (void)checkUpdateUserWithType:(EnableSignalType)type value:(BOOL)value {
    
    if(!self.inMeeting) {
        if(type == EnableSignalTypeAudio) {
            [UserDefaults setOpenMic:value];
        } else if(type == EnableSignalTypeVideo) {
            [UserDefaults setOpenCamera:value];
        }
        return;
    }
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    if(type == EnableSignalTypeAudio) {
        if(manager.roomModel.muteAllAudio == MuteAllAudioStateNoAllowUnmute) {
            [self gotoAlertApply:EnableSignalTypeAudio value:value];
            return;
        }
    }
    
    [self updateUserWithType:type value:value];
}

- (void)gotoAlertApply:(EnableSignalType)type value:(BOOL)value {
    UIViewController *vc = [VCManager getTopVC];
    
    // reset
    self.audioCell.switchBtn.on = !value;
    
    WEAK(self);
    [AlertViewUtil showAlertWithController:vc title:@"当前会议主持人设置为静音状态，是否申请打开麦克风？" cancelHandler:nil sureHandler:^(UIAlertAction * _Nullable action) {
    
        weakself.audioCell.switchBtn.on = value;
        [weakself updateUserWithType:type value:value];
    }];
}

- (void)updateUserWithType:(EnableSignalType)type value:(BOOL)value {
    
    WEAK(self);
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    NSString *userId = manager.ownModel.userId;

    [self setLoadingVisible:YES];
    [manager updateUserInfoWithUserId:userId value:value enableSignalType:type successBolck:^{
        
        //        if(type == EnableSignalTypeVideo) {
        //            [NSNotificationCenter.defaultCenter postNotificationName:NOTICENAME_LOCAL_MEDIA_CHANGED object:nil];
        //        }
        [weakself setLoadingVisible:NO];
    } failBlock:^(NSError * _Nonnull error) {
        if(type == EnableSignalTypeVideo) {
            weakself.videoCell.switchBtn.on = !value;
        } else if(type == EnableSignalTypeAudio) {
            weakself.audioCell.switchBtn.on = !value;
        }
        [weakself showToast:error.localizedDescription];
        [weakself setLoadingVisible:NO];
    }];
}

- (void)updateRoomWithIndex:(NSInteger)index value:(BOOL)on {
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    
    if (index == 0) {
        self.currentState = on ? MuteAllAudioStateNoAllowUnmute : MuteAllAudioStateUnmute;
    } else {
        self.currentState = on ? MuteAllAudioStateAllowUnmute : MuteAllAudioStateNoAllowUnmute;
    }
    [self.tableView reloadData];
    
    WEAK(self);
    [self setLoadingVisible:YES];
    [manager updateRoomInfoWithValue:self.currentState enableSignalType:ConfEnableRoomSignalTypeMuteAllAudio successBolck:^{
        
        [weakself setLoadingVisible:NO];
        
    } failBlock:^(NSError * _Nonnull error) {
        
        weakself.currentState = manager.roomModel.muteAllAudio;
        [weakself.tableView reloadData];
        
        [weakself showToast:error.localizedDescription];
        [weakself setLoadingVisible:NO];
    }];
}

- (void)setLoadingVisible:(BOOL)show {
    if(show) {
        [self.activityIndicator startAnimating];
        self.tableView.userInteractionEnabled = NO;
    } else {
        [self.activityIndicator stopAnimating];
        self.tableView.userInteractionEnabled = YES;
    }
}

@end
