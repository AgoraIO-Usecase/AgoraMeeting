//
//  PIPVideoCell.h
//  VideoConference
//
//  Created by SRS on 2020/5/15.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraRoomManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PIPVideoCell : UICollectionViewCell

@property (weak, nonatomic) UIView *boardView;
@property (assign, nonatomic) BOOL showWhite;
@property (assign, nonatomic) BOOL showScreen;

- (void)setOneUserModel:(ConfUserModel *)userModel;
- (void)setUser:(ConfUserModel *)userModel shareBoardModel:(ConfShareBoardUserModel *)boardModel;
- (void)setUser:(ConfUserModel *)userModel shareScreenModel:(ConfShareScreenUserModel *)screenModel;
- (void)setUser:(ConfUserModel *)userModel remoteUser:(ConfUserModel *)remoteUserModel;
- (void)updateWhiteView;
- (void)updateStateView;
@end

NS_ASSUME_NONNULL_END
