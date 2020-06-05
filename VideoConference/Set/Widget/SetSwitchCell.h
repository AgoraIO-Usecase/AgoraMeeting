//
//  SetSwitchCell.h
//  VideoConference
//
//  Created by SRS on 2020/5/10.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SwitchBlock)(BOOL on);

NS_ASSUME_NONNULL_BEGIN

@interface SetSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tipText;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

@property (copy, nonatomic) SwitchBlock block;

@end

NS_ASSUME_NONNULL_END
