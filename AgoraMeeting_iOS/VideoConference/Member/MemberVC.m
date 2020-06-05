//
//  MemberVC.m
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import "MemberVC.h"
#import "CommonNavigation.h"
#import "UserCell.h"
#import "MessageVC.h"
#import "SetVC.h"
#import "ShareLinkView.h"

@interface MemberVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CommonNavigation *nav;

@property (strong, nonatomic) NSArray<ConfUserModel *> *allUserListModel;

@end


@implementation MemberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allUserListModel = @[];
    self.nav.title.text = @"";
    self.nav.rightBtn.hidden = NO;
    [self.nav.rightBtn setImage:[UIImage imageNamed:@"set-icon"] forState:UIControlStateNormal];
    self.nav.rightBlock = ^(){
        SetVC *vc = [[SetVC alloc] initWithNibName:@"SetVC" bundle:nil];
        vc.isMemberSet = YES;
        [VCManager pushToVC:vc];
    };

    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
    
    [self addNotification];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:NOTICENAME_LOCAL_MEDIA_CHANGED object:nil];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:NOTICENAME_REMOTE_MEDIA_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:NOTICENAME_ROOM_INFO_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:NOTICENAME_SHARE_INFO_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:NOTICENAME_HOST_ROLE_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:NOTICENAME_IN_OUT_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:NOTICENAME_RECONNECT_CHANGED object:nil];
}

- (void)updateView {

    [self setLoadingVisible:NO];
    
    self.allUserListModel = AgoraRoomManager.shareManager.conferenceManager.userListModels;
    self.nav.title.text = [NSString stringWithFormat:@"成员（%ld）", (long)self.allUserListModel.count];
    [self.tableView reloadData];
    
    if(AgoraRoomManager.shareManager.conferenceManager.ownModel.role == ConfRoleTypeHost){
        self.nav.rightBtn.hidden = NO;
    } else {
        self.nav.rightBtn.hidden = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateView];
}

- (IBAction)onClickInvitation:(id)sender {
    ShareLinkView *vv = [ShareLinkView createViewWithXib];
    [vv showShareLinkViewInView:self.view];
}

- (IBAction)onClickIm:(id)sender {
    MessageVC *vc = [[MessageVC alloc] initWithNibName:@"MessageVC" bundle:nil];
    [VCManager pushToVC:vc];
}

#pragma mark UITableViewDelegate, UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    ConfUserModel *userModel = self.allUserListModel[indexPath.row];
    [cell updateViewWithModel:userModel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    ConfUserModel *userModel = self.allUserListModel[indexPath.row];
   
    if(userModel.role == ConfRoleTypeHost && indexPath.row != 0) {
        return;
    }
    
    ConfUserModel *ownModel = manager.ownModel;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    WEAK(self);
    NSString *audioText = userModel.enableAudio ? Localized(@"MuteAudio") : Localized(@"UnMuteAudio");
    UIAlertAction *muteAudio = [UIAlertAction actionWithTitle:audioText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 邀请
        if(indexPath.row != 0 && !userModel.enableAudio){
            [weakself gotoCheckInvite:EnableSignalTypeAudio model:userModel];
            return;
        }
        
        // apply
        if(manager.roomModel.muteAllAudio == MuteAllAudioStateNoAllowUnmute && !userModel.enableAudio) {
            
            if(manager.roomModel.hosts.count > 0){
                [weakself gotoCheckApply:EnableSignalTypeAudio model:manager.roomModel.hosts.firstObject];
            }
            return;
        }
    
        [weakself setLoadingVisible:YES];
        [manager updateUserInfoWithUserId:userModel.userId value:!userModel.enableAudio enableSignalType:EnableSignalTypeAudio successBolck:^{
            
            [weakself updateView];
//            [NSNotificationCenter.defaultCenter postNotificationName:indexPath.row == 0 ? NOTICENAME_LOCAL_MEDIA_CHANGED : NOTICENAME_REMOTE_MEDIA_CHANGED object:nil];
        } failBlock:^(NSError * _Nonnull error) {
            [weakself updateView];
            [weakself showToast:error.localizedDescription];
        }];
    }];
    if(indexPath.row == 0 || ownModel.role == ConfRoleTypeHost) {
        [alertController addAction:muteAudio];
    }
    
    NSString *videoText = userModel.enableVideo ? Localized(@"MuteVideo") : Localized(@"UnMuteVideo");
    UIAlertAction *muteVideo = [UIAlertAction actionWithTitle:videoText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 邀请
        if(indexPath.row != 0 && !userModel.enableVideo){
            [weakself gotoCheckInvite:EnableSignalTypeVideo model:userModel];
            return;
        }
        
        [weakself setLoadingVisible:YES];
        [manager updateUserInfoWithUserId:userModel.userId value:!userModel.enableVideo enableSignalType:EnableSignalTypeVideo successBolck:^{
            
            [weakself updateView];
//            [NSNotificationCenter.defaultCenter postNotificationName:indexPath.row == 0 ? NOTICENAME_LOCAL_MEDIA_CHANGED : NOTICENAME_REMOTE_MEDIA_CHANGED object:nil];
            
        } failBlock:^(NSError * _Nonnull error) {
            [weakself updateView];
            [weakself showToast:error.localizedDescription];
        }];
    }];
    if(indexPath.row == 0 || ownModel.role == ConfRoleTypeHost) {
        [alertController addAction:muteVideo];
    }

    if (userModel.role == ConfRoleTypeParticipant && ownModel.role == ConfRoleTypeHost && indexPath.row != 0) {
        UIAlertAction *setHost = [UIAlertAction actionWithTitle:Localized(@"SetHost") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [weakself setLoadingVisible:YES];
            [manager changeHostWithUserId:userModel.userId completeSuccessBlock:^{
//                [weakself updateView];
            } completeFailBlock:^(NSError * _Nonnull error) {
                [weakself updateView];
                [weakself showToast:error.localizedDescription];
            }];
        }];
        [alertController addAction:setHost];
    }
    
    // have shared
    if(NoNullString(manager.roomModel.createBoardUserId).integerValue > 0 && userModel.role == ConfRoleTypeParticipant) {
        
        // click self
        if(userModel.uid == ownModel.uid && ![ownModel.userId isEqualToString:NoNullString(manager.roomModel.createBoardUserId)]) {
            
            NSString *boardText = userModel.grantBoard ? Localized(@"CancelWhiteBoardControl") : Localized(@"ApplyWhiteBoard");
            
            UIAlertAction *whiteBoardControl = [UIAlertAction actionWithTitle:boardText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                if(!userModel.grantBoard){
                    [weakself gotoApplyOrInvite:EnableSignalTypeGrantBoard actionType:P2PMessageTypeActionApply userId:manager.roomModel.createBoardUserId];
                } else {
                    [weakself updateWhiteBoardStateWithValue:!userModel.grantBoard userId:userModel.userId];
                }
            }];
            [alertController addAction:whiteBoardControl];
            
        } else if(userModel.uid != ownModel.uid && [ownModel.userId isEqualToString:NoNullString(manager.roomModel.createBoardUserId)]) {
         
            NSString *boardText = userModel.grantBoard ? Localized(@"CancelWhiteBoardControl") : Localized(@"WhiteBoardControl");
            
            UIAlertAction *whiteBoardControl = [UIAlertAction actionWithTitle:boardText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [weakself updateWhiteBoardStateWithValue:!userModel.grantBoard userId:userModel.userId];
            }];
            [alertController addAction:whiteBoardControl];
        }
    }
    
    if(userModel.role == ConfRoleTypeParticipant && ownModel.role == ConfRoleTypeHost && indexPath.row != 0) {
        
        UIAlertAction *removeRoom = [UIAlertAction actionWithTitle:Localized(@"RemoveRoom") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [weakself setLoadingVisible:YES];
            [manager leftRoomWithUserId:userModel.userId successBolck:^{
                [weakself updateView];
            } failBlock:^(NSError * _Nonnull error) {
                [weakself updateView];
                [weakself showToast:error.localizedDescription];
            }];
        }];
        [alertController addAction:removeRoom];
    }
    
    [alertController addAction:cancel];
    
    [VCManager presentToVC:alertController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allUserListModel.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.f;
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

- (void)gotoCheckInvite:(EnableSignalType)type model:(ConfUserModel *)model {
    UIViewController *vc = [VCManager getTopVC];
    
    NSString *title = @"";
    if(type == EnableSignalTypeAudio){
        title = [NSString stringWithFormat:@"邀请%@打开麦克风", model.userName];
    } else if(type == EnableSignalTypeVideo){
        title = [NSString stringWithFormat:@"邀请%@打开摄像头", model.userName];
    }
    
    if(title.length == 0){
        return;
    }
    
    WEAK(self);
    [AlertViewUtil showAlertWithController:vc title:title cancelHandler:nil sureHandler:^(UIAlertAction * _Nullable action) {
        [weakself gotoApplyOrInvite:type actionType:P2PMessageTypeActionInvitation userId:model.userId];
    }];
}
- (void)gotoCheckApply:(EnableSignalType)type model:(ConfUserModel *)model {
    UIViewController *vc = [VCManager getTopVC];

    WEAK(self);
    [AlertViewUtil showAlertWithController:vc title:@"当前会议主持人设置为静音状态，是否申请打开麦克风？" cancelHandler:nil sureHandler:^(UIAlertAction * _Nullable action) {
        [weakself gotoApplyOrInvite:type actionType:P2PMessageTypeActionApply userId:model.userId];
    }];
}
- (void)gotoApplyOrInvite:(EnableSignalType)type actionType:(P2PMessageTypeAction)actionType userId:(NSString *)userId {

    WEAK(self);
    [self setLoadingVisible:YES];
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    [manager p2pActionWithType:type actionType:actionType userId:userId completeSuccessBlock:^{
         [weakself updateView];
    } completeFailBlock:^(NSError * _Nonnull error) {
        [weakself updateView];
        [weakself showToast:error.localizedDescription];
    }];
}

- (void)updateWhiteBoardStateWithValue:(BOOL)value userId:(NSString *)userId {
    [self setLoadingVisible:YES];
    
    WEAK(self);
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    [manager whiteBoardStateWithValue:value userId:userId completeSuccessBlock:^{
        [weakself updateView];
    } completeFailBlock:^(NSError * _Nonnull error) {
        [weakself updateView];
        [weakself showToast:error.localizedDescription];
    }];
}

@end
