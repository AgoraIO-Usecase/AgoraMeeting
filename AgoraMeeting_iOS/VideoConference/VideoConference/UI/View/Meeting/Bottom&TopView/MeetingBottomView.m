//
//  MeetingBottomView.m
//  VideoConference
//
//  Created by ZYP on 2020/12/29.
//  Copyright © 2020 agora. All rights reserved.
//

#import "MeetingBottomView.h"
#import "BottomItem.h"
#import "NibInitProtocol.h"

@interface MeetingBottomView ()<NibInitProtocol>

@property (weak, nonatomic) IBOutlet BottomItem *audioItem;
@property (weak, nonatomic) IBOutlet BottomItem *videoItem;
@property (weak, nonatomic) IBOutlet BottomItem *memberItem;
@property (weak, nonatomic) IBOutlet BottomItem *imItem;
@property (weak, nonatomic) IBOutlet BottomItem *moreItem;

@property (nonatomic, strong)MeetingBottomInfo *info;
@end

@implementation MeetingBottomView


- (void)awakeFromNib {
    [super awakeFromNib];
    [self initItem];
}

- (void)initItem {
    
    UIColor *inActiveTextColor = [UIColor colorWithHexString:@"989898"];
    UIColor *activeTextColor = [UIColor colorWithHexString:@"4DA1FF"];
    
    BottomItemInfo *audioInfo = [BottomItemInfo new];
    audioInfo.title = Localized(@"meeting_t46");
    audioInfo.activeImageName = @"bar-speaker1";
    audioInfo.inActiveImageName = @"bar-speaker0";
    audioInfo.inActiveTextColor = inActiveTextColor;
    audioInfo.activeTextColor = activeTextColor;
    [self.audioItem configInfo:audioInfo];
    [self.audioItem configState:BottomItemStateInactive timeCount:0];
    
    BottomItemInfo *videoInfo = [BottomItemInfo new];
    videoInfo.title = Localized(@"meeting_t47");
    videoInfo.activeImageName = @"bar-camera1";
    videoInfo.inActiveImageName = @"bar-camera0";
    videoInfo.inActiveTextColor = inActiveTextColor;
    videoInfo.activeTextColor = activeTextColor;
    [self.videoItem configInfo:videoInfo];
    [self.videoItem configState:BottomItemStateInactive timeCount:0];
    
    BottomItemInfo *memberInfo = [BottomItemInfo new];
    memberInfo.title = Localized(@"meeting_t48");
    memberInfo.activeImageName = @"bar_user0";
    memberInfo.inActiveImageName = @"bar_user0";
    memberInfo.inActiveTextColor = inActiveTextColor;
    memberInfo.activeTextColor = inActiveTextColor;
    [self.memberItem configInfo:memberInfo];
    [self.memberItem configState:BottomItemStateActive timeCount:0];
   
    BottomItemInfo *imInfo = [BottomItemInfo new];
    imInfo.title = Localized(@"meeting_t49");
    imInfo.activeImageName = @"bar_chat0";
    imInfo.inActiveImageName = @"bar_chat0";
    imInfo.inActiveTextColor = inActiveTextColor;
    imInfo.activeTextColor = inActiveTextColor;
    [self.imItem configInfo:imInfo];
    [self.imItem configState:BottomItemStateActive timeCount:0];
    
    BottomItemInfo *moreInfo = [BottomItemInfo new];
    moreInfo.title = Localized(@"meeting_t50");
    moreInfo.activeImageName = @"bar_more0";
    moreInfo.inActiveImageName = @"bar_more0";
    moreInfo.inActiveTextColor = inActiveTextColor;
    moreInfo.activeTextColor = inActiveTextColor;
    [self.moreItem configInfo:moreInfo];
    [self.moreItem configState:BottomItemStateActive timeCount:0];
    
    WEAK(self);
    
    
    self.audioItem.block = ^{
        if([weakself.delegate respondsToSelector:@selector(meetingBottomView:didTapButtonWithType:)]) {
            [weakself.delegate meetingBottomView:self didTapButtonWithType:MeetingBottomViewButtonTypeAudio];
        }
    };
    self.videoItem.block = ^{
        if([weakself.delegate respondsToSelector:@selector(meetingBottomView:didTapButtonWithType:)]) {
            [weakself.delegate meetingBottomView:self didTapButtonWithType:MeetingBottomViewButtonTypeVideo];
        }
    };
    self.memberItem.block = ^{
        if([weakself.delegate respondsToSelector:@selector(meetingBottomView:didTapButtonWithType:)]) {
            [weakself.delegate meetingBottomView:self didTapButtonWithType:MeetingBottomViewButtonTypeMember];
        }
    };
    self.imItem.block = ^{
        if([weakself.delegate respondsToSelector:@selector(meetingBottomView:didTapButtonWithType:)]) {
            [weakself.delegate meetingBottomView:self didTapButtonWithType:MeetingBottomViewButtonTypeChat];
        }
    };
    self.moreItem.block = ^{
        if([weakself.delegate respondsToSelector:@selector(meetingBottomView:didTapButtonWithType:)]) {
            [weakself.delegate meetingBottomView:self didTapButtonWithType:MeetingBottomViewButtonTypeMore];
        }
    };
}

- (BottomItemState)getVideoState {
    return self.videoItem.getState;
}

- (BottomItemState)getAudioState {
    return self.audioItem.getState;
}

- (void)updateVideoItem:(BottomItemState)state timeCount:(NSInteger)timeCount {
    [self.videoItem configState:state timeCount:timeCount];
    if (timeCount == 0) {
        [self setVideEnable:true];
    }
}

- (void)updateAudioItem:(BottomItemState)state timeCount:(NSInteger)timeCount {
    [self.audioItem configState:state timeCount:timeCount];
    if (timeCount == 0) {
        [self setAudioEnable:true];
    }
}

- (void)setVideEnable:(BOOL)enable {
    [self.videoItem setButtonEnable:enable];
}

- (void)setAudioEnable:(BOOL)enable {
    [self.audioItem setButtonEnable:enable];
}

- (void)updateImRedDocCount:(NSInteger)count {
    [self.imItem setRedDoc:count];
}

+ (instancetype)instanceFromNib {
    NSString *className = NSStringFromClass(MeetingBottomView.class);
    return [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil].firstObject;
}


@end
