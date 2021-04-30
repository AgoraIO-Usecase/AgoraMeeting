//
//  SetArrowCell.h
//  VideoConference
//
//  Created by SRS on 2020/5/11.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetArrowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tipText;

+ (NSString *)idf;
+ (NSString *)nibName;

@end

NS_ASSUME_NONNULL_END
