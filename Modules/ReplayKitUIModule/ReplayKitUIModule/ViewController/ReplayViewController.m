//
//  ReplayNoVideoViewController.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/10.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "ReplayViewController.h"
#import <ReplayKitModule/ReplayKitModule.h>
#import "ReplayControlView.h"
#import "TouchButton.h"
#import "LoadingView.h"
#import "UIView+Constraint.h"

@interface ReplayViewController ()<ReplayControlViewDelegate, CombineReplayDelegate>

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet ReplayControlView *controlView;
@property (weak, nonatomic) IBOutlet TouchButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *playBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet LoadingView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *teacherView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultTeacherImage;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (nonatomic, assign) BOOL playFinished;
// can seek when has buffer only for m3u8 video
@property (nonatomic, assign) BOOL canSeek;

// replay
@property (nonatomic, strong) CombineReplayManager *combineReplayManager;
@property (nonatomic, weak) UIView *boardView;
@property (nonatomic, weak) UIView *videoView;

@end

@implementation ReplayViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self initData];
}

- (void)initData {
    
    self.canSeek = NO;
    self.playFinished = NO;
    
    self.controlView.delegate = self;

    self.combineReplayManager = [CombineReplayManager new];
    self.combineReplayManager.delegate = self;

    NSAssert(self.model.videoPath != nil, @"can't find record video");
    [self setupVideoReplay];
    [self setupWhiteReplay];
}

- (void)setupVideoReplay {
    
    __weak typeof(self) weakself = self;
    AVPlayer *player = [self.combineReplayManager setupVideoReplayWithURL:[NSURL URLWithString:self.model.videoPath]];
    dispatch_async(dispatch_get_main_queue(), ^{
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        [weakself.videoView.layer addSublayer:playerLayer];
    });
}

- (void)setupWhiteReplay {
    
    ReplayManagerModel *replayManagerModel = [ReplayManagerModel new];
    replayManagerModel.uuid = self.model.boardId;
    replayManagerModel.uutoken = self.model.boardToken;
    replayManagerModel.startTime = @(self.model.startTime).stringValue;
    replayManagerModel.endTime = @(self.model.endTime).stringValue;
    replayManagerModel.boardView = self.boardView;
    
    __weak typeof(self) weakself = self;
    [self.combineReplayManager setupWhiteReplayWithValue:replayManagerModel completeSuccessBlock:^{
        
        [weakself seekToTimeInterval:0 completionHandler:^(BOOL finished) {
        }];
        
    } completeFailBlock:^(NSError * _Nullable error) {
        [weakself showTipWithMessage:error.description];
    }];
}

- (void)showTipWithMessage:(NSString *)toastMessage {

    self.tipLabel.hidden = NO;
    [self.tipLabel setText: toastMessage];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disappearTipLabel) object:nil];
    [self performSelector:@selector(disappearTipLabel) withObject:toastMessage afterDelay:2];
}
- (void)disappearTipLabel {
    self.tipLabel.hidden = YES;
}

- (void)setupView {
    
    UIView *videoView = [[UIView alloc] initWithFrame:self.teacherView.bounds];
    videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.teacherView addSubview:videoView];
    self.videoView = videoView;
    
    UIView *boardView = [CombineReplayManager createWhiteBoardView];
    [self.whiteboardBaseView insertSubview:boardView belowSubview:self.playBackgroundView];
    [boardView equalTo:self.whiteboardBaseView];
    self.boardView = boardView;
    
    self.backButton.layer.cornerRadius = 6;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)dealloc {
    [self.combineReplayManager releaseResource];
    self.combineReplayManager = nil;
}

#pragma mark Click Event
- (IBAction)onWhiteBoardClick:(id)sender {
    self.controlView.hidden = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
}

- (IBAction)onPlayClick:(id)sender {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
    
    [self setPlayViewsVisible:YES];
    
    __weak typeof(self) weakself = self;
    if(self.playFinished) {
        self.playFinished = NO;
        [self seekToTimeInterval:0 completionHandler:^(BOOL finished) {
            [weakself.combineReplayManager play];
        }];
    } else {
        [self.combineReplayManager play];
    }
}

- (IBAction)onBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setLoadingViewVisible:(BOOL)onPlay {
    onPlay ? [self.loadingView showLoading] : [self.loadingView hiddenLoading];
    onPlay ? (self.playBackgroundView.hidden = NO) : (self.playBackgroundView.hidden = YES);
}

- (void)setPlayViewsVisible:(BOOL)onPlay {
    self.playBackgroundView.hidden = onPlay;
    self.playButton.hidden = onPlay;
    self.controlView.playOrPauseBtn.selected = onPlay;
}

- (void)hideControlView {
    self.controlView.hidden = YES;
}

- (void)seekToTimeInterval:(NSTimeInterval)seconds completionHandler:(void (^)(BOOL finished))completionHandler {
    CMTime cmTime = CMTimeMakeWithSeconds(seconds, 100);
    [self.combineReplayManager seekToTime:cmTime completionHandler:completionHandler];
}

- (NSTimeInterval)timeTotleDuration {
    return (NSInteger)(self.model.endTime - self.model.startTime) * 0.001;
}

#pragma mark ReplayControlViewDelegate
- (void)sliderTouchBegan:(float)value {
    if(!self.canSeek) {
        return;
    }
    self.controlView.sliderView.isdragging = YES;
}

- (void)sliderValueChanged:(float)value {
    if(!self.canSeek) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    if ([self timeTotleDuration] > 0) {
        Float64 seconds = [self timeTotleDuration] * value;
        [self seekToTimeInterval:seconds completionHandler:^(BOOL finished) {
        }];
    }
}

- (void)sliderTouchEnded:(float)value {
    if(!self.canSeek) {
        self.controlView.sliderView.isdragging = NO;
        return;
    }
    
    if ([self timeTotleDuration] == 0) {
        self.controlView.sliderView.value = 0;
        return;
    }
    self.controlView.sliderView.value = value;
    float currentTime = [self timeTotleDuration] * value;
    
    __weak typeof(self) weakself = self;
    [self seekToTimeInterval:currentTime completionHandler:^(BOOL finished) {
        NSString *currentTimeStr = [weakself convertTimeSecond: currentTime];
        NSString *totleTimeStr = [weakself convertTimeSecond: [weakself timeTotleDuration]];
        NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
        weakself.controlView.timeLabel.text = timeStr;

        weakself.controlView.sliderView.isdragging = NO;
    }];
}

- (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}

- (void)sliderTapped:(float)value {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    self.controlView.sliderView.isdragging = YES;
    
    if([self timeTotleDuration] > 0) {
        NSInteger currentTime = [self timeTotleDuration] * value;
        __weak typeof(self) weakself = self;
        [self seekToTimeInterval:currentTime completionHandler:^(BOOL finished) {
            NSString *currentTimeStr = [weakself convertTimeSecond: currentTime];
            NSString *totleTimeStr = [weakself convertTimeSecond: [weakself timeTotleDuration]];
            NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
            weakself.controlView.timeLabel.text = timeStr;
            
            weakself.controlView.sliderView.isdragging = NO;
        }];
    } else {
        
        self.controlView.sliderView.value = 0;
        self.controlView.sliderView.isdragging = NO;
    }
}

- (void)playPauseButtonClicked:(BOOL)play {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    [self setPlayViewsVisible:play];
    
    if(play) {
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
        
        __weak typeof(self) weakself = self;
        if(self.playFinished) {
            self.playFinished = NO;
            [self seekToTimeInterval:0 completionHandler:^(BOOL finished) {
                [weakself.combineReplayManager play];
            }];
        } else {
            [self.combineReplayManager play];
        }
        
    } else {
        [self.combineReplayManager pause];
    }
}

#pragma mark CombineReplayDelegate
- (void)combinePlayTimeChanged:(NSTimeInterval)time {
    if(self.controlView.sliderView.isdragging){
        return;
    }
    
    if([self timeTotleDuration] > 0){
        float value = time / [self timeTotleDuration];
        self.controlView.sliderView.value = value;
        NSString *totleTimeStr = [self convertTimeSecond: [self timeTotleDuration]];
        NSString *currentTimeStr = [self convertTimeSecond: time];
        NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
        self.controlView.timeLabel.text = timeStr;
    }
}
- (void)combinePlayStartBuffering {
    if(self.playButton.hidden){
        [self setLoadingViewVisible:YES];
    }
}
- (void)combinePlayEndBuffering {
    if(self.playButton.hidden){
        [self setLoadingViewVisible:NO];
    }
    self.canSeek = YES;
}
- (void)combinePlayDidFinish {
    [self.combineReplayManager pause];

    [self setLoadingViewVisible:NO];
    [self setPlayViewsVisible:NO];
    
    self.playFinished = YES;
    self.controlView.hidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
}
- (void)combinePlayPause {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    self.controlView.hidden = NO;
    [self setPlayViewsVisible:NO];
}
- (void)combinePlayError:(NSError * _Nullable)error {
    [self showTipWithMessage:error.description];
}

@end
