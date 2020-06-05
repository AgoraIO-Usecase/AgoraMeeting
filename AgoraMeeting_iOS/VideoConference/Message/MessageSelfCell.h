//
//  MessageSelfCell.h
//  VideoConference
//
//  Created by SRS on 2020/5/13.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageSelfCell : UITableViewCell

- (void)updateWithTime:(NSInteger)time message:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
