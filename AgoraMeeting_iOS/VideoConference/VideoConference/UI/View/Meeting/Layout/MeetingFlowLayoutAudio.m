//
//  MeetingFlowLayoutAudio.m
//  VideoConference
//
//  Created by ZYP on 2021/1/4.
//  Copyright © 2021 agora. All rights reserved.
//

#import "MeetingFlowLayoutAudio.h"
#import "UIScreen+Extension.h"

@interface MeetingFlowLayoutAudio (){
    CGFloat _padding;
}

@property (nonatomic, assign)CGFloat padding;

@property (nonatomic,strong) NSMutableArray *attrs;
/** 每行item数量*/
@property (nonatomic,assign) NSInteger rowCount;
/** 每列item数量*/
@property (nonatomic,assign) NSInteger columCount;

@end

@implementation MeetingFlowLayoutAudio

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        _padding = 30.0;
        
        CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
        CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
        CGFloat topSafeAreaHeight = UIScreen.topSafeAreaHeight;
        CGFloat bottomSafeAreaHeight = UIScreen.bottomSafeAreaHeight;
        CGFloat contentHeigh = screenHeight - topSafeAreaHeight - bottomSafeAreaHeight;
        CGFloat topBarHeight = 64.0;
        CGFloat bottomBarHeight = 55.0;
        CGFloat gap = 0.0;
        self.rowCount = 3;
        self.columCount = 4;
        self.itemSize = CGSizeMake((screenWidth - 4.0*gap - 2.0*_padding)/3.0, (contentHeigh - topBarHeight - bottomBarHeight - 6.0*gap - 2*_padding)/self.columCount);
        self.minimumLineSpacing = gap;
        self.minimumInteritemSpacing = gap;
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
    NSInteger itemsPerPage = 12;
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger pages = itemCount/itemsPerPage + (itemCount%itemsPerPage > 0 ? 1 : 0);
    CGFloat width = pages * self.collectionView.bounds.size.width;
    CGFloat hegith = self.collectionView.bounds.size.height;
    return CGSizeMake(width, hegith);
}

#pragma mark - private method
// 设置item布局属性
- (void)resetItemLocation:(UICollectionViewLayoutAttributes *)attr {
    if(attr.representedElementKind != nil) {
        return;
    }
    
    NSInteger itemsPerPage = 12;
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:attr.indexPath.section];
    NSInteger pages = itemCount/itemsPerPage + (itemCount%itemsPerPage > 0 ? 1 : 0);
    NSInteger currentPage = attr.indexPath.row / itemsPerPage;
    NSInteger pageItems = 0;
    if (pages == 1) { /** 只有一页 */
        pageItems = itemCount;
    }
    else if (currentPage == pages - 1) {
        pageItems = itemCount % 12 == 0 ? 12 : itemCount % 12 ;
    }
    else {
        pageItems = itemsPerPage;
    }
    [self resetPageItemLocation:attr currentPage:currentPage pageItems:pageItems];
}

- (void)resetPageItemLocation:(UICollectionViewLayoutAttributes *)attr
                  currentPage:(NSInteger)currentPage
                    pageItems:(NSInteger)pageItems {
    // 获取当前section的item数量
    NSInteger itemCount = pageItems;
    // 获取当前item的大小
    CGFloat itemW = self.itemSize.width;
    CGFloat itemH = self.itemSize.height;
    CGFloat screenWidth = self.collectionView.bounds.size.width;
    CGFloat pageOffset = currentPage * screenWidth;
    CGFloat centerX = self.collectionView.bounds.size.width/2 - itemW/2;
    CGFloat centerY = self.collectionView.bounds.size.height/2 - itemH/2;
    if(itemCount == 1) {
        CGFloat xOffset = centerX + pageOffset;
        CGFloat yOffset = centerY;
        attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
        return;
    }
    
    if(itemCount == 2) {
        NSInteger index = attr.indexPath.item%12;
        if(index == 0) {
            CGFloat xOffset = centerX - itemW/3 * 2 + pageOffset;
            CGFloat yOffset = centerY;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else {
            CGFloat xOffset = centerX + itemW/3 * 2 + pageOffset;
            CGFloat yOffset = centerY;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
    }
    
    if(itemCount == 3) {
        NSInteger index = attr.indexPath.item%12;
        if(index == 0) {
            CGFloat xOffset = 10 + pageOffset;
            CGFloat yOffset = centerY;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 1) {
            CGFloat xOffset = centerX + pageOffset;
            attr.frame = CGRectMake(xOffset, centerY, itemW, itemH);
            return;
        }
        else {
            CGFloat xOffset = screenWidth - itemW - 10 + pageOffset;
            CGFloat yOffset = centerY;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
    }
    
    if(itemCount == 4) {
        NSInteger index = attr.indexPath.item%12;
        if(index == 0) {
            CGFloat xOffset = 10 + pageOffset;
            CGFloat yOffset = centerY - itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 1) {
            CGFloat xOffset = centerX + pageOffset;
            CGFloat yOffset = centerY - itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 2) {
            CGFloat xOffset = screenWidth - itemW - 10 + currentPage * screenWidth;
            CGFloat yOffset = centerY - itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else {
            CGFloat xOffset = centerX + currentPage * screenWidth;
            CGFloat yOffset = centerY + itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
    }
    
    if(itemCount == 5) {
        NSInteger index = attr.indexPath.item%12;
        if(index == 0) {
            CGFloat xOffset = 10 + pageOffset;
            CGFloat yOffset = centerY - itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 1) {
            CGFloat xOffset = centerX + pageOffset;
            CGFloat yOffset = centerY - itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 2) {
            CGFloat xOffset = screenWidth - itemW - 10  + pageOffset;
            CGFloat yOffset = centerY - itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 3) {
            CGFloat xOffset = centerX - itemH/2  + pageOffset;
            CGFloat yOffset = centerY + itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else {
            CGFloat xOffset = centerX + itemH/2  + pageOffset;
            CGFloat yOffset = centerY + itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
    }
    
    if(itemCount == 6) {
        NSInteger index = attr.indexPath.item%12;
        if(index == 0) {
            CGFloat xOffset = 10 + pageOffset;
            CGFloat yOffset = centerY - itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 1) {
            CGFloat xOffset = centerX + pageOffset;
            CGFloat yOffset = centerY - itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 2) {
            CGFloat xOffset = self.collectionView.bounds.size.width - itemW - 10 + pageOffset;
            CGFloat yOffset = centerY - itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 3) {
            CGFloat xOffset = 10 + pageOffset;
            CGFloat yOffset = centerY + itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 4) {
            CGFloat xOffset = centerX + pageOffset;
            CGFloat yOffset = centerY + itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else {
            CGFloat xOffset = screenWidth - itemW - 10 + pageOffset;
            CGFloat yOffset = centerY + itemH/2;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
    }
    
    if(itemCount == 7) {
        NSInteger index = attr.indexPath.item%12;
        if(index == 0) {
            CGFloat xOffset = 10 + pageOffset;
            CGFloat yOffset = centerY - itemH;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 1) {
            CGFloat xOffset = centerX + pageOffset;
            CGFloat yOffset = centerY - itemH;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 2) {
            CGFloat xOffset = self.collectionView.bounds.size.width - itemW - 10 + pageOffset;
            CGFloat yOffset = centerY - itemH;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 3) {
            CGFloat xOffset = 10+ pageOffset;
            CGFloat yOffset = centerY;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 4) {
            CGFloat xOffset = centerX + pageOffset;
            CGFloat yOffset = centerY;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else if(index == 5) {
            CGFloat xOffset = screenWidth - itemW - 10 + pageOffset;
            CGFloat yOffset = centerY;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
        else {
            CGFloat xOffset = centerX + pageOffset;
            CGFloat yOffset = centerY + itemH;
            attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
            return;
        }
    }
    
    
    CGFloat lineDis = self.minimumLineSpacing;
    CGFloat itemDis = self.minimumInteritemSpacing;
    if(itemCount > 7) {
        NSInteger itemIndex = attr.indexPath.item%12;
        NSInteger xIndex = [self getXIndexInPage:itemIndex];
        NSInteger yIndex = [self getYIndexInPage:itemIndex];
        
        CGFloat xOffset = xIndex * (itemW + lineDis) + _padding + currentPage * screenWidth;
        CGFloat yOffset = yIndex * (itemH + itemDis) + _padding;
        
        attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
        return;
    }
}

- (NSInteger)getXIndexInPage:(NSInteger)itemIndexInPage {
    switch (itemIndexInPage) {
        case 0: case 3: case 6: case 9:
            return 0;
        case 1: case 4: case 7: case 10:
            return 1;
        case 2: case 5: case 8: case 11:
            return 2;
        default:
            assert(true);
            return 0;
    }
}

- (NSInteger)getYIndexInPage:(NSInteger)itemIndexInPage {
    switch (itemIndexInPage) {
        case 0: case 1: case 2:
            return 0;
        case 3: case 4: case 5:
            return 1;
        case 6: case 7: case 8:
            return 2;
        case 9: case 10: case 11:
            return 3;
        default:
            assert(true);
            return 0;
    }
}


@end
