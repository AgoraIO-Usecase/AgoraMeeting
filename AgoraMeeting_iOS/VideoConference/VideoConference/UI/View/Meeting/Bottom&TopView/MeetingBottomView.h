//
//  MeetingBottomView.h
//  VideoConference
//
//  Created by ZYP on 2020/12/29.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingBottomInfo.h"
#import "BottomItem.h"

typedef NS_ENUM(NSUInteger, MeetingBottomViewButtonType) {
    MeetingBottomViewButtonTypeMember,
    MeetingBottomViewButtonTypeChat,
    MeetingBottomViewButtonTypeMore,
    MeetingBottomViewButtonTypeVideo,
    MeetingBottomViewButtonTypeAudio,
};

@class MeetingBottomView;

@protocol MeetingBottomViewDelegate <NSObject>

- (void)meetingBottomView:(MeetingBottomView * _Nonnull)view didTapButtonWithType:(MeetingBottomViewButtonType)type;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MeetingBottomView : UIView

@property (nonatomic, weak)id<MeetingBottomViewDelegate> delegate;


+ (instancetype)instanceFromNib;
- (BottomItemState)getVideoState;
- (BottomItemState)getAudioState;
- (void)updateVideoItem:(BottomItemState)state timeCount:(NSInteger)timeCount;
- (void)updateAudioItem:(BottomItemState)state timeCount:(NSInteger)timeCount;
- (void)setVideEnable:(BOOL)enable;
- (void)setAudioEnable:(BOOL)enable;
- (void)updateImRedDocCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
