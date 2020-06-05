//
//  AgoraFlowLayout.m
//  VideoConference
//
//  Created by SRS on 2020/5/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraFlowLayout.h"

@interface AgoraFlowLayout ()
@property (strong, nonatomic) NSMutableArray *allAttributes;

@end

@implementation AgoraFlowLayout
- (void)prepareLayout {
    [super prepareLayout];
    
    self.allAttributes = [NSMutableArray array];
    
    NSUInteger numberOfSections = self.collectionView.numberOfSections;
    for (NSUInteger j = 0; j < numberOfSections; j++) {
        NSUInteger count = [self.collectionView numberOfItemsInSection:j];
        for (NSUInteger i = 0; i < count; i++) {
           NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:j];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.allAttributes addObject:attributes];
        }
    }
}

- (CGSize)collectionViewContentSize {
    return [super collectionViewContentSize];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        return [super layoutAttributesForItemAtIndexPath:indexPath];
    }
    
    NSUInteger item = indexPath.item;
    NSUInteger x;
    NSUInteger y;
    [self targetPositionWithItem:item resultX:&x resultY:&y];
    NSUInteger item2 = [self originItemAtX:x y:y];
    NSIndexPath *theNewIndexPath = [NSIndexPath indexPathForItem:item2 inSection:indexPath.section];

    UICollectionViewLayoutAttributes *theNewAttr = [super layoutAttributesForItemAtIndexPath:theNewIndexPath];
    theNewAttr.indexPath = indexPath;
    return theNewAttr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *tmp = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attr in attributes) {
        for (UICollectionViewLayoutAttributes *attr2 in self.allAttributes) {
            if (attr.indexPath.row == attr2.indexPath.row && attr.indexPath.section == attr2.indexPath.section) {
                [tmp addObject:attr2];
                break;
            }
        }
    }
    return tmp;
}

// 根据 item 计算目标item的位置
// x 横向偏移  y 竖向偏移
- (void)targetPositionWithItem:(NSUInteger)item
                       resultX:(NSUInteger *)x
                       resultY:(NSUInteger *)y {
    NSUInteger page = item/(self.itemCountPerRow * self.rowCount);

    NSUInteger theX = item % self.itemCountPerRow + page * self.itemCountPerRow;
    NSUInteger theY = item / self.itemCountPerRow - page * self.rowCount;
    if (x != NULL) {
        *x = theX;
    }
    if (y != NULL) {
        *y = theY;
    }
}

// 根据偏移量计算item
- (NSUInteger)originItemAtX:(NSUInteger)x
                          y:(NSUInteger)y {
    NSUInteger item = x * self.rowCount + y;
    return item;
}

- (CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if(section == 0){
        return 0;
    } else {
        return 2;
    }
}

- (CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
     
    CGSize size = collectionView.bounds.size;
    if(indexPath.section == 0){
        return size;
    }
    
    NSInteger width = (size.width - 2) * 0.5;
    NSInteger height = (size.height - 2) * 0.5;
    
    return CGSizeMake(width, height);
}
@end
