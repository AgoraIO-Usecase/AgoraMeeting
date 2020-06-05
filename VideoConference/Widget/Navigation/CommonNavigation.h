//
//  CommonNavigation.h
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BackBlock)(void);
typedef void (^RightBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface CommonNavigation : UIView

@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (copy, nonatomic) BackBlock backBlock;
@property (copy, nonatomic) RightBlock rightBlock;

@end

NS_ASSUME_NONNULL_END
