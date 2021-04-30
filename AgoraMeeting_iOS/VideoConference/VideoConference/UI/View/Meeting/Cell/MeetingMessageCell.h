//
//  MessageCell.h
//  VideoConference
//
//  Created by ZYP on 2021/1/5.
//  Copyright © 2021 agora. All rights reserved.
//

#import <UIKit/UIKit.h>



@class MeetingMessageModel, MeetingMessageCell;

@protocol MeetingMessageCellDelegate <NSObject>

- (void)meetingMessageCell:(MeetingMessageCell * _Nonnull)cell didTapButton:(MeetingMessageModel * _Nonnull)model;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MeetingMessageCell : UITableViewCell

- (void)setModel:(MeetingMessageModel *)model;
- (void)setIndex:(NSInteger)index;
@property (nonatomic, weak)id<MeetingMessageCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
