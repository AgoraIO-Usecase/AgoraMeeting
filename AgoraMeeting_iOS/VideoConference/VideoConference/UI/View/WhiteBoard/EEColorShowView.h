//
//  EEColorShowView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/1.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EEColorShowViewDelegate <NSObject>

- (void)eeColorShowViewDidSelecteColor:(NSString *_Nonnull)colorString;

@end


NS_ASSUME_NONNULL_BEGIN

@interface EEColorShowView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *colorFlowLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *colorCollectionView;
@property (nonatomic, weak) id<EEColorShowViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
