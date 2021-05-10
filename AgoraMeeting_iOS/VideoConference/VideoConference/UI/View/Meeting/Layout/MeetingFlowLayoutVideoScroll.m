//
//  MeetingFlowLayoutVideoScroll.m
//  VideoConference
//
//  Created by ZYP on 2021/1/5.
//  Copyright © 2021 agora. All rights reserved.
//

#import "MeetingFlowLayoutVideoScroll.h"
#import "UIScreen+Extension.h"

@interface MeetingFlowLayoutVideoScroll ()

@property (nonatomic, assign)CGFloat padding;

@property (nonatomic,strong) NSMutableArray *attrs;

@end

@implementation MeetingFlowLayoutVideoScroll

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.itemSize = CGSizeMake(82, 110);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    // 获取section数量
    self.attrs = [NSMutableArray new];
    NSInteger section = [self.collectionView numberOfSections];
    for (int i = 0; i < section; i++) {
        // 获取当前分区的item数量
        NSInteger items = [self.collectionView numberOfItemsInSection:i];
        for (int j = 0; j < items; j++) {
            // 设置item位置
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.attrs addObject:attr];
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath].copy;
    [self resetItemLocation:attr];
    return attr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *tmp = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attr2 in self.attrs) {
        CGRectIntersectsRect(attr2.frame, rect);
        [tmp addObject:attr2];
    }
    return tmp;
}

- (CGSize)collectionViewContentSize {
    NSInteger items = [self.collectionView numberOfItemsInSection:0];
    CGFloat width = (items * (self.itemSize.width + 5)) + 5;
    return CGSizeMake(width, self.itemSize.height);
}

#pragma mark - private method
// 设置item布局属性
- (void)resetItemLocation:(UICollectionViewLayoutAttributes *)attr {
    if(attr.representedElementKind != nil) {
        return;
    }
    // 获取当前item的大小
    CGFloat itemW = self.itemSize.width;
    CGFloat itemH = self.itemSize.height;
    NSInteger row = attr.indexPath.row;
    CGFloat xOffset = row * (itemW + 5) + 5;
    
    attr.frame = CGRectMake(xOffset, 0, itemW, itemH);
}


@end
