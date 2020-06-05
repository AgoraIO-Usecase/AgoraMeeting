//
//  VideoCell.h
//  VideoConference
//
//  Created by SRS on 2020/5/15.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraRoomManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoCell : UICollectionViewCell

- (void)setShareBoardModel:(ConfShareBoardUserModel *)userModel;
- (void)setShareScreenModel:(ConfShareScreenUserModel *)userModel;
- (void)setUserModel:(ConfUserModel * _Nullable)userModel;

@end

NS_ASSUME_NONNULL_END
