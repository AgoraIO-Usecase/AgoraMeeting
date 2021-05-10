//
//  SetLabelCell.h
//  VideoConference
//
//  Created by SRS on 2020/5/10.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetLabelCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tipText;
@property (weak, nonatomic) IBOutlet UILabel *valueText;

+ (NSString *)idf;
+ (NSString *)nibName;

@end

NS_ASSUME_NONNULL_END
