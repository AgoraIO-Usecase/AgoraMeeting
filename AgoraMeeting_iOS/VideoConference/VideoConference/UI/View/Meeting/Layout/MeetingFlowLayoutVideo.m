//
//  MeetingFlowLayout.m
//  VideoConference
//
//  Created by ZYP on 2020/12/31.
//  Copyright © 2020 agora. All rights reserved.
//

#import "MeetingFlowLayoutVideo.h"
#import "UIScreen+Extension.h"

@interface MeetingFlowLayoutVideo ()

@property (nonatomic,strong) NSMutableArray *attrs;
@property (nonatomic,strong) NSMutableDictionary *pageDict;
/** 每行item数量*/
@property (nonatomic,assign) NSInteger rowCount;
/** 每列item数量*/
@property (nonatomic,assign) NSInteger columCount;

@end

@implementation MeetingFlowLayoutVideo

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
        CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
        CGFloat contentHeigh = screenHeight-UIScreen.topSafeAreaHeight-UIScreen.bottomSafeAreaHeight;
        CGFloat topBarHeight = 64.0;
        CGFloat bottomBarHeight = 55.0;
        CGFloat gap = 2.0;
        self.itemSize = CGSizeMake((screenWidth - gap)/2.0, (contentHeigh - topBarHeight - bottomBarHeight - gap)/2.0);
        self.rowCount = 2;
        self.columCount = 2;
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.minimumLineSpacing = 2;
        self.minimumInteritemSpacing = 2;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    if (self.attrs != nil) {
        [self.attrs removeAllObjects];
    }
    self.attrs = [NSMutableArray new];
    // 获取section数量
    NSInteger section = [self.collectionView numberOfSections];
    _pageDict = [NSMutableDictionary dictionary];
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
    // 将所有section页面数量相加
    NSInteger allPagesCount = 0;
    for (NSString *page in [self.pageDict allKeys]) {
        allPagesCount += allPagesCount + [self.pageDict[page] integerValue];
    }
    CGFloat width = allPagesCount * self.collectionView.bounds.size.width;
    CGFloat hegith = self.collectionView.bounds.size.height;
    return CGSizeMake(width, hegith);
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
    // 获取当前section的item数量
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:attr.indexPath.section];
    // 获取横排item数量
    CGFloat width = self.collectionView.bounds.size.width;
    // 获取行间距和item最小间距
    CGFloat lineDis = self.minimumLineSpacing;
    CGFloat itemDis = self.minimumInteritemSpacing;
    // 获取当前item的索引index
    NSInteger index = attr.indexPath.item;
    // 获取每页item数量
    NSInteger allCount = self.rowCount * self.columCount;
    // 获取item在当前section的页码
    NSInteger page = index / allCount;
    // 获取item x y方向偏移量
    NSInteger xIndex = index % self.rowCount;
    NSInteger yIndex = (index - page * allCount)/self.rowCount;
    // 获取x y方向偏移距离
    CGFloat edgeDis = 0;
    CGFloat xOffset = xIndex * (itemW + lineDis) + edgeDis;
    CGFloat yOffset = yIndex * (itemH + itemDis) + edgeDis;
    // 获取每个item占了几页
    NSInteger sectionPage = (itemCount % allCount == 0) ? itemCount/allCount : (itemCount/allCount + 1);
    // 保存每个section的page数量
    [self.pageDict setObject:@(sectionPage) forKey:[NSString stringWithFormat:@"%lu",attr.indexPath.section]];
    // 将所有section页面数量相加
    NSInteger allPagesCount = 0;
    for (NSString *page in [self.pageDict allKeys]) {
        allPagesCount += allPagesCount + [self.pageDict[page] integerValue];
    }
    // 获取到的数减去最后一页的页码数
    NSInteger lastIndex = self.pageDict.allKeys.count - 1;
    allPagesCount -= [self.pageDict[[NSString stringWithFormat:@"%lu",lastIndex]] integerValue];
    xOffset += page * width + allPagesCount * width;
    
    attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
}

@end
