//
//  BottomItem.h
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BottomItemBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface BottomItem : UIView

@property (nonatomic, strong) NSString *imageName0;
@property (nonatomic, strong) NSString *imageName1;

@property (nonatomic, strong) NSString *tip;
@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL isSelected;

@property (copy, nonatomic) BottomItemBlock block;

@end

NS_ASSUME_NONNULL_END
