//
//  SpeakerLeftItem.h
//  VideoConference
//
//  Created by ZYP on 2020/12/30.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SpeakerModel;

@interface SpeakerLeftItem : UIView

@property (weak, nonatomic) IBOutlet UIImageView *shareView;
@property (weak, nonatomic) IBOutlet UIImageView *audioView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *hostView;

+ (instancetype)instanceFromNib;
- (void)setModel:(SpeakerModel *)model;

@end

NS_ASSUME_NONNULL_END
