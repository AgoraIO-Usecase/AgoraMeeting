//
//  MeetingNavigation.h
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LeftBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface MeetingNavigation : UIView

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *time;

@property (copy, nonatomic) LeftBlock leftBlock;

- (void)startTimerWithCount:(NSInteger)timeCount;
- (void)setAudioRouting:(NSInteger)routing;

@end

NS_ASSUME_NONNULL_END
