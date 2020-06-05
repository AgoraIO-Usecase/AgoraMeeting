//
//  AgoraFlowLayout.h
//  VideoConference
//
//  Created by SRS on 2020/5/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraFlowLayout : UICollectionViewFlowLayout

// 一行中 cell的个数
@property (nonatomic) NSUInteger itemCountPerRow;//2
// 一页显示多少行
@property (nonatomic) NSUInteger rowCount;// 2

- (CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section;

- (CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
    
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
