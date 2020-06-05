//
//  MeetingVC.m
//  VideoConference
//
//  Created by SRS on 2020/5/12.
//  Copyright © 2020 agora. All rights reserved.
//

#import "MeetingVC.h"
#import "PIPVideoCell.h"
#import "VideoCell.h"
#import "PaddingLabel.h"
#import "AgoraRoomManager.h"
#import "MeetingNavigation.h"
#import "BottomBar.h"
#import "AgoraFlowLayout.h"

@interface MeetingVC ()<UICollectionViewDelegate, UICollectionViewDataSource, WhiteManagerDelegate, ConferenceDelegate>

@property (weak, nonatomic) IBOutlet PaddingLabel *tipLabel;
@property (weak, nonatomic) IBOutlet MeetingNavigation *nav;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet BottomBar *bottomBar;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) AgoraFlowLayout *layout;

@property (strong, nonatomic) NSMutableArray<ConfUserModel *> *allUserListModel;

@property (strong, nonatomic) WhiteInfoModel *whiteInfoModel;
@property (weak, nonatomic) PIPVideoCell *pipVideoCell;

@end

@implementation MeetingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allUserListModel = [NSMutableArray array];
    
    [self initView];
    [self addNotification];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupWhiteBoard];
    });
    
    AgoraRoomManager.shareManager.conferenceManager.delegate = self;
    
    [self initData];
    [self startDispatchGroup: YES];
}

- (void)updateViewOnReconnected {
    WEAK(self);
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    [manager getConfRoomInfoWithSuccessBlock:^(ConfRoomInfoModel * _Nonnull roomInfoModel) {
        
        [weakself initData];
        [weakself startDispatchGroup: NO];
        [NSNotificationCenter.defaultCenter postNotificationName:NOTICENAME_RECONNECT_CHANGED object:nil];
    } failBlock:^(NSError * _Nonnull error) {
        
    }];
}

- (void)setupWhiteBoard {
    
    WhiteManager *whiteManager = AgoraRoomManager.shareManager.whiteManager;
    [whiteManager initWhiteSDK:self.pipVideoCell.boardView dataSourceDelegate:self];
    
    WEAK(self);
    ConferenceManager *conferenceManager = AgoraRoomManager.shareManager.conferenceManager;
    
    [conferenceManager getWhiteInfoWithSuccessBlock:^(WhiteInfoModel * _Nonnull model) {
        [whiteManager joinWhiteRoomWithBoardId:model.boardId boardToken:model.boardToken whiteWriteModel:conferenceManager.ownModel.grantBoard completeSuccessBlock:^{
            
//            [whiteManager disableWhiteDeviceInputs:!conferenceManager.ownModel.grantBoard];
            [whiteManager currentWhiteScene:^(NSInteger sceneCount, NSInteger sceneIndex) {
                [whiteManager moveWhiteToContainer:sceneIndex];
            }];
            
        } completeFailBlock:^(NSError * _Nullable error) {
            [weakself showToast:error.localizedDescription];
        }];
    } failBlock:^(NSError * _Nonnull error) {
        [weakself showToast:error.localizedDescription];
    }];
}

- (void)startDispatchGroup:(BOOL)initMedia {
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    
    dispatch_group_t group = dispatch_group_create();
    __block NSString *errMsg = @"";
    
    if(initMedia) {
        // init media
        dispatch_group_enter(group);
        ClientRole clientRole = ClientRoleBroadcaster;
        [manager initMediaWithClientRole:clientRole successBolck:^{
            dispatch_group_leave(group);
        } failBlock:^(NSInteger errorCode) {
            errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"JoinMediaFailedText", nil), (long)errorCode];
            dispatch_group_leave(group);
        }];
    }
    
    // get totle users
    dispatch_group_enter(group);
    [manager getUserListWithSuccessBlock:^{
        dispatch_group_leave(group);
    } failBlock:^(NSError * _Nonnull error) {
        errMsg = error.localizedDescription;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if(errMsg != nil && errMsg.length > 0) {
            [self showToast:errMsg];
        } else {
            [self onReloadView];
        }
    });
}

- (void)initView {
    //    UICollectionView
    [self.collectionView registerNib:[UINib nibWithNibName:@"PIPVideoCell" bundle:nil] forCellWithReuseIdentifier:@"PIPVideoCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellWithReuseIdentifier:@"VideoCell"];
    
    AgoraFlowLayout *layout = [AgoraFlowLayout new];
    layout = [AgoraFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemCountPerRow = 2;
    layout.rowCount = 2;
    [self.collectionView setCollectionViewLayout:layout];
    self.layout = layout;
    
    self.tipLabel.hidden = YES;
    self.tipLabel.layer.cornerRadius = 11;
    self.tipLabel.clipsToBounds = YES;
    self.tipLabel.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
}

- (void)initData {
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    self.nav.title.text = manager.roomModel.roomName;
    [self.nav startTimerWithCount: manager.roomModel.startTime];
    
    [self.allUserListModel addObject:manager.ownModel];
    for(ConfUserModel *hostModel in manager.roomModel.hosts) {
        if(hostModel.uid != manager.ownModel.uid){
            [self.allUserListModel addObject:hostModel];
        }
    }
    [self.collectionView  reloadData];
    
    [self updateStateView];
}

- (void)updateStateView {
   
    [self.pipVideoCell updateStateView];
    
    // bottom bar
    [self.bottomBar updateView];
}

- (void)addNotification {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onLocalVideoStateChange) name:NOTICENAME_LOCAL_MEDIA_CHANGED object:nil];
}

- (void)onReloadView {
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    self.allUserListModel = [NSMutableArray arrayWithArray:manager.userListModels];
    
    NSInteger shareScreenCount = manager.roomModel.shareScreenUsers.count;
    NSInteger shareBoardCount = manager.roomModel.shareBoardUsers.count;
    NSInteger allUserCount = self.allUserListModel.count;
    NSInteger count = shareScreenCount + shareBoardCount + allUserCount - 2;
    if(count <= 0) {
        self.pageControl.hidden = YES;
    } else {
        self.pageControl.hidden = NO;
        self.pageControl.currentPage = 0;
        self.pageControl.numberOfPages = 1 + count / 4 + (count % 4 == 0 ? 0 : 1);
    }
    [self.collectionView reloadData];
    
    [self updateStateView];
}

- (void)onLocalVideoStateChange {
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    self.allUserListModel = [NSMutableArray arrayWithArray:manager.userListModels];
       
    
    [self reloadPIPVideoCell];
    [self.bottomBar updateView];
}

#pragma mark UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    NSInteger count = self.allUserListModel.count + manager.roomModel.shareScreenUsers.count + manager.roomModel.shareBoardUsers.count - 2;
    if(self.allUserListModel.count == 0) {
        return 0;
    } else if(count <= 0) {
        return 1;
    }
    return 2;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [self.layout minimumLineSpacingForSectionAtIndex:section];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [self.layout minimumInteritemSpacingForSectionAtIndex:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        PIPVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PIPVideoCell" forIndexPath:indexPath];
        self.pipVideoCell = cell;
        [self reloadPIPVideoCell];
        return cell;
    } else {
        ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
        NSInteger shareScreenCount = manager.roomModel.shareScreenUsers.count > 0 ? 1 : 0;
        NSInteger shareBoardCount = manager.roomModel.shareBoardUsers.count > 0 ? 1 : 0;
        NSInteger allUserCount = self.allUserListModel.count;
        
        VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
        if(shareScreenCount > indexPath.row + 1) {
            ConfShareScreenUserModel *model = manager.roomModel.shareScreenUsers[indexPath.row + 1];
            [cell setShareScreenModel:model];
            
        } else if(shareBoardCount > indexPath.row + 1 - shareScreenCount) {
            ConfShareBoardUserModel *model = manager.roomModel.shareBoardUsers[indexPath.row + 1 - shareScreenCount];
            [cell setShareBoardModel:model];
        } else if(allUserCount > indexPath.row + 2 - shareScreenCount - shareBoardCount) {
            ConfUserModel *model = self.allUserListModel[indexPath.row + 2 - shareScreenCount - shareBoardCount];
            [cell setUserModel:model];
        } else {
            [cell setUserModel:nil];
        }
        return cell;
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(section == 0) {
        return 1;
    }
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;

    BOOL shared = NO;
    if(manager.roomModel.shareScreenUsers.count > 0 || manager.roomModel.shareBoardUsers.count > 0){
        shared = YES;
    }
    
    NSInteger count = self.allUserListModel.count + (shared ? 1 : 0) - 2;
    if(count % 4 == 0){
        return count;
    } else {
        return count + 4 - count % 4;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.layout collectionView:collectionView sizeForItemAtIndexPath:indexPath];
}

#pragma mark scrollViewDidScroll
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollViewDidEndScroll];
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollViewDidEndScroll];
    });
}
- (void)scrollViewDidEndScroll {
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *indexPath = indexPaths.firstObject;
    if(self.pageControl.numberOfPages > 0) {
        if(indexPath.section == 0) {
            self.pageControl.currentPage = 0;
        } else {
            NSInteger index = indexPath.row + 1;
            self.pageControl.currentPage = index / 4 + (index % 4 == 0 ? 0 : 1);
        }
    }
}

#pragma mark WhitePlayDelegate
- (void)whiteRoomStateChanged {
    [AgoraRoomManager.shareManager.whiteManager currentWhiteScene:^(NSInteger sceneCount, NSInteger sceneIndex) {
        [AgoraRoomManager.shareManager.whiteManager moveWhiteToContainer:sceneIndex];
    }];
}

#pragma mark ConferenceDelegate
- (void)didReceivedPeerSignal:(ConfSignalP2PInfoModel * _Nonnull)model {
    if(model.action == P2PMessageTypeTip) {
        
        [self handleConfirmAlertView:model];
        // 判断申请还是邀请
    } else if(model.action == P2PMessageTypeActionInvitation || model.action == P2PMessageTypeActionApply) {
        
        [self handleApplyOrInvitationAlertView: model];
        
    } else if(model.action == P2PMessageTypeActionRejectApply || model.action == P2PMessageTypeActionRejectInvitation) {
        
        [self handleRejectAlertView: model];
    }
}
- (void)didReceivedSignalInOut:(NSArray<ConfSignalChannelInOutInfoModel *> *)models {
    //
    [self onReloadView];
    
    ConfSignalChannelInOutInfoModel *model = models.lastObject;
    if(model == nil){
        return;
    }
    
    NSString *tipText = @"";
    if(model.state == 0) {
        tipText = [NSString stringWithFormat:@"\"%@\"离开房间", model.userName];
    } else {
        tipText = [NSString stringWithFormat:@"\"%@\"进入房间", model.userName];
    }
    
    self.tipLabel.hidden = NO;
    [self.tipLabel setText: tipText];
    
    WEAK(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakself.tipLabel.hidden = YES;
    });
    
    [NSNotificationCenter.defaultCenter postNotificationName:NOTICENAME_IN_OUT_CHANGED object:nil];
}
- (void)didReceivedSignalRoomInfo:(ConfSignalChannelRoomModel *)model {

    if(model.muteAllAudio != MuteAllAudioStateUnmute){
        [self onReloadView];
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:NOTICENAME_ROOM_INFO_CHANGED object:nil];
    
    if(AgoraRoomManager.shareManager.conferenceManager.ownModel.role == ConfRoleTypeHost) {
        return;
    }
    
    if (model.state == 0) {
        [AlertViewUtil showAlertWithController:[VCManager getTopVC] title:@"主持人结束了会议" sureHandler:^(UIAlertAction * _Nullable action) {
            [VCManager popRootView];
        }];
        return;
    }
    
    NSString *title = @"";
    NSString *message = @"";
    if(model.muteAllAudio == MuteAllAudioStateUnmute){
        title = @"主持人解除静音控制";
        message = @"您现在自主控制麦克风了哦!";
    } else if(model.muteAllAudio == MuteAllAudioStateAllowUnmute){
        title = @"主持人开启了静音控制";
        message = @"你可以再次打开麦克风!";
    } else if(model.muteAllAudio == MuteAllAudioStateNoAllowUnmute){
        title = @"主持人开启了静音控制";
        message = @"你可以通过申请打开麦克风!";
    }
    [AlertViewUtil showAlertWithController:[VCManager getTopVC] title:title message:message cancelText:nil sureText:@"我知道了" cancelHandler:nil sureHandler:nil];
    
}
- (void)didReceivedSignalUserInfo:(ConfUserModel *)model {
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    if(model.uid == manager.ownModel.uid){
        [NSNotificationCenter.defaultCenter postNotificationName:NOTICENAME_LOCAL_MEDIA_CHANGED object:nil];
    } else {
        [self onReloadView];
        [NSNotificationCenter.defaultCenter postNotificationName:NOTICENAME_REMOTE_MEDIA_CHANGED object:nil];
    }
}
- (void)didReceivedSignalShareBoard:(ConfSignalChannelBoardModel *)model {
    
    [self onReloadView];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTICENAME_SHARE_INFO_CHANGED object:nil];
}
- (void)didReceivedSignalShareScreen:(ConfSignalChannelScreenModel *)model {
    
    [self onReloadView];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTICENAME_SHARE_INFO_CHANGED object:nil];
}
- (void)didReceivedSignalHostChange:(NSArray<ConfUserModel*> *)hostModels {
    [self onReloadView];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTICENAME_HOST_ROLE_CHANGED object:nil];
}
- (void)didReceivedSignalKickoutChange:(ConfSignalChannelKickoutModel*)model {
    
    [AlertViewUtil showAlertWithController:[VCManager getTopVC] title:@"主持人把你移出房间" sureHandler:^(UIAlertAction * _Nullable action) {
        [VCManager popRootView];
    }];
}
- (void)didReceivedMessage:(MessageInfoModel * _Nonnull)model {
    UIViewController *vc = [VCManager getTopVC];
    if([vc isKindOfClass:self.class]) {
        [self.bottomBar addUnreadMsgCount];
    }
    [AgoraRoomManager.shareManager.messageInfoModels addObject:model];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTICENAME_MESSAGE_CHANGED object:nil];
}
- (void)didReceivedConnectionStateChanged:(ConnectionState)state {
    if(state == ConnectionStateReconnected) {
        [self updateViewOnReconnected];
    } else if(state == ConnectionStateAnotherLogged) {
        [self showToast:NSLocalizedString(@"LoginOnAnotherDeviceText", nil)];
        [AgoraRoomManager releaseResource];
        [VCManager popRootView];
    }
}
- (void)didAudioRouteChanged:(AudioOutputRouting)routing {
    [self.nav setAudioRouting:routing];
}
- (void)networkTypeGrade:(NetworkGrade)grade uid:(NSInteger)uid {
    
}

#pragma mark Handel Tip View
- (void)handleConfirmAlertView:(ConfSignalP2PInfoModel*)model {
    
    NSString *title = @"";
    if(model.action == P2PMessageTypeActionOpenTip) {
        if(model.type == P2PMessageTypeActionTypeAudio){
            title = @"主持人同意了你打开麦克风的申请";
        } else if(model.type == P2PMessageTypeActionTypeBoard){
            title = @"你现在有白板的操作权限了";
        }
    } else if(model.action == P2PMessageTypeActionCloseTip) {
        if(model.type == P2PMessageTypeActionTypeVideo){
            title = @"主持人关闭了你的摄像头";
        } else if(model.type == P2PMessageTypeActionTypeAudio){
            title = @"主持人关闭了你的麦克风";
        } else if(model.type == P2PMessageTypeActionTypeBoard){
            title = @"你现在没有白板的操作权限了";
        }
    }
    if(title.length > 0){
        [AlertViewUtil showAlertWithController:[VCManager getTopVC] title:title];
    }
}
    
- (void)handleRejectAlertView:(ConfSignalP2PInfoModel*)model {
    NSString *title = @"";
    if(model.action == P2PMessageTypeActionRejectApply) {
        if(model.type == P2PMessageTypeActionTypeBoard) {
            title = [NSString stringWithFormat:@"%@拒绝了共享白板操作的申请", model.userName];
        } else if(model.type == P2PMessageTypeActionTypeAudio) {
            title = @"主持人拒绝了打开麦克风的申请";
        }
    } else {
        if(model.type == P2PMessageTypeActionTypeAudio) {
            title = [NSString stringWithFormat:@"%@拒绝了打开麦克风的邀请", model.userName];
        } else if(model.type == P2PMessageTypeActionTypeVideo) {
            title = [NSString stringWithFormat:@"%@拒绝了打开摄像头的邀请", model.userName];
        }
    }
    if(title.length > 0){
        [AlertViewUtil showAlertWithController:[VCManager getTopVC] title:title];
    }
}

- (void)handleApplyOrInvitationAlertView:(ConfSignalP2PInfoModel*)model {
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    
    NSString *title = @"";
    EnableSignalType type = EnableSignalTypeVideo;
    P2PMessageTypeAction actionType = P2PMessageTypeActionRejectApply;
    NSString *noticeName = @"";
    NSString *userId = @"";
    if(model.action == P2PMessageTypeActionInvitation) {
        
        noticeName = NOTICENAME_LOCAL_MEDIA_CHANGED;
        userId = manager.ownModel.userId;
        if(model.type == P2PMessageTypeActionTypeAudio) {
            title = @"主持人邀请你打开麦克风";
            type = EnableSignalTypeAudio;
        } else if(model.type == P2PMessageTypeActionTypeVideo) {
            title = @"主持人邀请你打开摄像头";
            type = EnableSignalTypeVideo;
        }
        actionType = P2PMessageTypeActionRejectInvitation;
    } else {
        noticeName = NOTICENAME_REMOTE_MEDIA_CHANGED;
        userId = model.userId;
        if(model.type == P2PMessageTypeActionTypeBoard) {
            title = [NSString stringWithFormat:@"%@申请共享白板操作的权限", model.userName];
            type = EnableSignalTypeGrantBoard;
            noticeName = @"";
        } else if(model.type == P2PMessageTypeActionTypeAudio) {
            title = [NSString stringWithFormat:@"%@申请打开麦克风", model.userName];
            type = EnableSignalTypeAudio;
        }
        actionType = P2PMessageTypeActionRejectApply;
    }
    
    if(title.length == 0){
        return;
    }
    
    [AlertViewUtil showAlertWithController:[VCManager getTopVC] title:title message:nil cancelText:@"拒绝" sureText:@"同意" cancelHandler:^(UIAlertAction * _Nullable action) {

        [manager p2pActionWithType:type actionType:actionType userId:model.userId completeSuccessBlock:^{
             
        } completeFailBlock:^(NSError * _Nonnull error) {
            BaseViewController *vc = (BaseViewController*)[VCManager getTopVC];
            if(vc){
                [vc showToast:error.localizedDescription];
            }
        }];
        
    } sureHandler:^(UIAlertAction * _Nullable action) {
        [manager updateUserInfoWithUserId:userId value:YES enableSignalType:type successBolck:^{
            
            if(NoNullString(noticeName).length > 0){
                [NSNotificationCenter.defaultCenter postNotificationName:noticeName object:nil];
            }
            
        } failBlock:^(NSError * _Nonnull error) {
            BaseViewController *vc = (BaseViewController*)[VCManager getTopVC];
            if(vc){
                [vc showToast:error.localizedDescription];
            }
        }];
    }];
}


-(void) reloadPIPVideoCell {
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    NSInteger shareScreenCount = manager.roomModel.shareScreenUsers.count;
    NSInteger shareBoardCount = manager.roomModel.shareBoardUsers.count;
    NSInteger allUserCount = self.allUserListModel.count;
    NSInteger count = shareScreenCount + shareBoardCount + allUserCount;
    
    // only self
    ConfUserModel *selfModel = self.allUserListModel.firstObject;
    if(count == 1) {
        [self.pipVideoCell setOneUserModel:selfModel];
    } else {
        if(shareScreenCount > 0) {
            ConfShareScreenUserModel *remoteModel = manager.roomModel.shareScreenUsers.firstObject;
            [self.pipVideoCell setUser:selfModel shareScreenModel:remoteModel];
            
        } else if(shareBoardCount > 0) {
            ConfShareBoardUserModel *remoteModel = manager.roomModel.shareBoardUsers.firstObject;
            [self.pipVideoCell setUser:selfModel shareBoardModel:remoteModel];
        } else {
            ConfUserModel *remoteModel = self.allUserListModel[1];
            [self.pipVideoCell setUser:selfModel remoteUser:remoteModel];
        }
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [AgoraRoomManager releaseResource];
}
@end
