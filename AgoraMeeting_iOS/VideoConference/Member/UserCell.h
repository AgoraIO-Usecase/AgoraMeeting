//
//  UserCell.h
//  VideoConference
//
//  Created by SRS on 2020/5/13.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraRoomManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UITableViewCell

- (void)updateViewWithModel:(ConfUserModel *)userModel;

@end

NS_ASSUME_NONNULL_END
