//
//  SetSwitchCell.h
//  VideoConference
//
//  Created by SRS on 2020/5/10.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetSwitchCellDelegate <NSObject>

- (void)setSwitchCellSwitchValueDidChange:(BOOL)on AtIndexPath:(NSIndexPath * _Nonnull)indexPath;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SetSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tipText;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

@property (nonatomic, weak) id<SetSwitchCellDelegate> delegate;
@property (nonatomic, strong)NSIndexPath *indexPath;

+ (NSString *)idf;
+ (NSString *)nibName;

@end

NS_ASSUME_NONNULL_END
