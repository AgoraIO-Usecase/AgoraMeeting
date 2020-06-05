//
//  SetCenterTextCell.h
//  VideoConference
//
//  Created by SRS on 2020/5/10.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetCenterTextCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tipText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;

@end

NS_ASSUME_NONNULL_END
