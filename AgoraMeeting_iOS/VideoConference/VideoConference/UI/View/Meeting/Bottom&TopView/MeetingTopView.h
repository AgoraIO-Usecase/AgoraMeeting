//
//  MeetingTopView.h
//  VideoConference
//
//  Created by ZYP on 2020/12/28.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingTopViewDelegate.h"

typedef void (^LeftBlock)(void);

typedef NS_ENUM(NSInteger, MeetingTopViewAudioType) {
    MeetingTopViewAudioTypeCloseSpreak = 0,
    MeetingTopViewAudioTypeOpenSpreak = 1,
    MeetingTopViewAudioTypeEar = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface MeetingTopView : UIView

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *time;

@property (copy, nonatomic) LeftBlock leftBlock;
@property (weak, nonatomic) id<MeetingTopViewDelegate> delegate;

- (void)startTimerWithCount:(NSInteger)timeCount;
- (void)stopTime;
- (void)setAudioRouting:(MeetingTopViewAudioType)type;
+ (instancetype)instanceFromNib;

@end

NS_ASSUME_NONNULL_END
