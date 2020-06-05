//
//  MeetingNavigation.m
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import "MeetingNavigation.h"
#import "AgoraRoomManager.h"
#import "ScoreAlertVC.h"
#import "BaseViewController.h"

@interface MeetingNavigation() {
    dispatch_source_t timer;
}
@property (strong, nonatomic) IBOutlet MeetingNavigation *navigation;

@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *directionBtn;

@property (nonatomic,assign) NSInteger timeCount;
@end

@implementation MeetingNavigation

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.navigation];
        [self.navigation equalTo:self];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    self.speakerBtn.userInteractionEnabled = NO;
}

- (IBAction)onSpeakerClick:(id)sender {
}

- (void)setAudioRouting:(AudioOutputRouting)routing {
    if(routing == AudioOutputRoutingHeadset || routing == AudioOutputRoutingHeadsetNoMic || routing ==  AudioOutputRoutingHeadsetBluetooth) {
        [self.speakerBtn setImage:[UIImage imageNamed:@"speaker-ear"] forState:UIControlStateNormal];
    } else {
        [self.speakerBtn setImage:[UIImage imageNamed:@"speaker-open"] forState:UIControlStateNormal];
    }
}

- (IBAction)onSwitchCamera:(id)sender {
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    [manager switchCamera];
}

- (IBAction)onLeftMeeting:(id)sender {
    
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    NSString *userId = manager.ownModel.userId;
    BOOL isHost = manager.ownModel.role == ConfRoleTypeHost;

    WEAK(self);
    
    UIAlertAction *left = [UIAlertAction actionWithTitle:@"退出会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [manager leftRoomWithUserId:userId successBolck:^{
            
            [weakself showScoreAlert];
            
        } failBlock:^(NSError * _Nonnull error) {
            [weakself showMsgToast:error.localizedDescription];
        }];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    if(isHost) {

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"如果您不想中断会议，\n请在离开前指定新的主持人" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *finish = [UIAlertAction actionWithTitle:@"结束会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [weakself setLoadingVisible:YES];
            [manager updateRoomInfoWithValue:0 enableSignalType:ConfEnableRoomSignalTypeState successBolck:^{
                
                [weakself setLoadingVisible:NO];
                [weakself showScoreAlert];
                            
            } failBlock:^(NSError * _Nonnull error) {
                [weakself setLoadingVisible:NO];
                [weakself showMsgToast:error.localizedDescription];
            }];
            
        }];
        [alertController addAction:finish];
        
        [alertController addAction:left];
        [alertController addAction:cancel];
        
        [VCManager presentToVC:alertController];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        [alertController addAction:left];
        [alertController addAction:cancel];
        
        [VCManager presentToVC:alertController];
    }
}

- (void)showScoreAlert {

    ScoreAlertVC *vc = [[ScoreAlertVC alloc] initWithNibName:@"ScoreAlertVC" bundle:nil];
    
    WEAK(self);
    vc.block = ^(){
        if(weakself.leftBlock == nil){
            [VCManager popTopView];
        } else {
            weakself.leftBlock();
        }
    };
    [VCManager presentToVC:vc];
}

- (void)showMsgToast:(NSString *)title {
    UIViewController *vc = [VCManager getTopVC];
    if (vc != nil && title != nil && title.length > 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc.view makeToast:title];
        });
    }
}

- (void)startTimerWithCount:(NSInteger)timeCount {
    
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval currenTimeInterval = [currentDate timeIntervalSince1970];
    self.timeCount = (NSInteger)((currenTimeInterval * 1000 - timeCount) * 0.001);
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
    
    WEAK(self);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        NSInteger hours = weakself.timeCount / 3600;
        NSInteger minutes = (weakself.timeCount - (3600 * hours)) / 60;
        NSInteger seconds = weakself.timeCount % 60;
        NSString *strTime = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", (long)hours, (long)minutes, (long)seconds];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.time.text = strTime;
        });
        self.timeCount++;
    });
    dispatch_resume(timer);
}
- (void)stopTimer {
    if (timer) {
        dispatch_source_cancel(timer);
    }
}

- (void)setLoadingVisible:(BOOL)show {
    
    BaseViewController *vc = (BaseViewController*)[VCManager getTopVC];
    if(vc == nil || ![vc isKindOfClass:BaseViewController.class]){
        return;
    }
    
    if(show) {
        [vc.activityIndicator startAnimating];
        vc.view.userInteractionEnabled = NO;
    } else {
        [vc.activityIndicator stopAnimating];
        vc.view.userInteractionEnabled = YES;
    }
}

- (void)dealloc {
    [self stopTimer];
}
@end
