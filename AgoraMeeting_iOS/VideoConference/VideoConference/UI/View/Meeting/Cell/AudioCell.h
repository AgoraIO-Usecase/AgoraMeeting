//
//  AudioCell.h
//  VideoConference
//
//  Created by ZYP on 2021/1/5.
//  Copyright © 2021 agora. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface AudioCell : UICollectionViewCell

+ (instancetype)instanceFromNib;
- (void)setImageName:(NSString *)imageName
                name:(NSString *)name
         audioEnable:(BOOL)audioEnable;

@end

NS_ASSUME_NONNULL_END
