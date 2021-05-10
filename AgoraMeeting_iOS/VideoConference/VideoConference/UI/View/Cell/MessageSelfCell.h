//
//  MessageSelfCell.h
//  VideoConference
//
//  Created by SRS on 2020/5/13.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MessageSelfCellDelegate <NSObject>

- (void)messageSelfCelldidTapFailButton:(NSIndexPath *)indexPath;

@end

typedef NS_ENUM(NSUInteger, MessageSelfCellStatus) {
    MessageSelfCellStatusSending  = 0,
    MessageSelfCellStatusSuccess = 1,
    MessageSelfCellStatusFail = 2,
    MessageSelfCellStatusRecv = 3,
};

@interface MessageSelfCell : UITableViewCell

@property (nonatomic, strong)NSIndexPath *indexPath;
@property (nonatomic, weak)id<MessageSelfCellDelegate> delegate;

- (void)updateWithTime:(NSInteger)time message:(NSString *)msg;
- (void)updateStatus:(MessageSelfCellStatus)status;
- (void)updateTimeShow:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
