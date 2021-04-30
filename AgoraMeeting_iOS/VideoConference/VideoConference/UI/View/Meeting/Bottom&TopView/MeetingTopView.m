//
//  MeetingTopView.m
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import "MeetingTopView.h"
#import "MeetingTopViewDelegate.h"
#import "NibInitProtocol.h"
#import <AVKit/AVKit.h>

@interface MeetingTopView() <NibInitProtocol> {
    dispatch_source_t timer;
}

@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *directionBtn;
@property (nonatomic,assign) NSInteger timeCount;
@property (nonatomic, assign)MeetingTopViewAudioType type;
@property (nonatomic, strong)AVRoutePickerView *routePickerView;
@end

@implementation MeetingTopView

- (void)awakeFromNib {
    [super awakeFromNib];
    _routePickerView = [[AVRoutePickerView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_routePickerView setHidden:true];
    [self addSubview:_routePickerView];
    [_speakerBtn addTarget:self action:@selector(didTapSpeakerBtn) forControlEvents:UIControlEventTouchUpInside];
    [self setAudioRouting:MeetingTopViewAudioTypeOpenSpreak];
}

- (void)setAudioRouting:(MeetingTopViewAudioType)type {
    self.type = type;
    NSString *imageName = @"";
    switch (type) {
        case MeetingTopViewAudioTypeCloseSpreak:
            imageName = @"";
            break;
        case MeetingTopViewAudioTypeOpenSpreak:
            imageName = @"speaker-open";
            break;
        case MeetingTopViewAudioTypeEar:
            imageName = @"speaker-ear";
            break;
        default:
            break;
    }
    
    [self.speakerBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (IBAction)onSpeakerClick:(id)sender {}

- (IBAction)onSwitchCamera:(id)sender {
    if ([self.delegate respondsToSelector:@selector(meetingTopViewDidTapCameraButton)]) {
        [self.delegate meetingTopViewDidTapCameraButton];
    }
}

- (IBAction)onLeftMeeting:(id)sender {
    if ([self.delegate respondsToSelector:@selector(meetingTopViewDidTapLeaveButton)]) {
        [self.delegate meetingTopViewDidTapLeaveButton];
    }
}
- (IBAction)shareButtonTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(meetingTopViewDidTapShareButton)]) {
        [self.delegate meetingTopViewDidTapShareButton];
    }
}

- (void)startTimerWithCount:(NSInteger)timeCount
{
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

- (void)stopTime {
    if (timer) {
        dispatch_suspend(timer);
    }
}

- (void)didTapSpeakerBtn {
    [AVAudioSession.sharedInstance setCategory:AVAudioSession.sharedInstance.category error:nil];
    for (UIView *sub in [_routePickerView subviews]) {
        if ([sub isKindOfClass:UIButton.class]) {
            UIButton *btn = (UIButton *)sub;
            [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)stopTimer
{
    if (timer) {
        dispatch_source_cancel(timer);
    }
}

- (void)dealloc
{
    [self stopTimer];
}

+ (instancetype)instanceFromNib
{
    NSString *className = NSStringFromClass(MeetingTopView.class);
    return [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil].firstObject;
}

@end
