//
//  StickyHeaderFlowLayout.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "StickyHeaderFlowLayout.h"

@interface StickyHeaderFlowLayout () {
    NSInteger _numberOfItemFrameSections;
}

@property (nonatomic) CGSize contentSize;
@property (nonatomic, strong) NSMutableDictionary *layoutAttributesIndexPath;
@property (nonatomic, strong) NSMutableDictionary *layoutAttributesHeader;
@property (nonatomic, strong) NSMutableDictionary *itemFrames;
@property (nonatomic, strong) NSArray *headerFrames;
@property (nonatomic, strong) NSMutableSet *visibleCellsIndexPaths;
@property (nonatomic, strong) NSMutableDictionary *currentVisibleCellAttributes;
@end

@implementation StickyHeaderFlowLayout

- (void)clearItemFrames
{
    [self.itemFrames removeAllObjects];
    [self.layoutAttributesIndexPath removeAllObjects];
    [self.layoutAttributesHeader removeAllObjects];
}

- (void)dealloc
{
    [self clearItemFrames];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    // set to NULL so it is not released by accident in dealloc
    _numberOfColumns = (IS_IPAD)?4:3;
    _layoutAttributesIndexPath = [NSMutableDictionary dictionary];
    _layoutAttributesHeader = [NSMutableDictionary dictionary];
    _itemFrames = [NSMutableDictionary dictionary];
    self.sectionInset = UIEdgeInsetsZero;
    self.minimumLineSpacing = 1;
    self.minimumInteritemSpacing = 1;
    self.headerReferenceSize = CGSizeZero;
    self.footerReferenceSize = CGSizeZero;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

#pragma mark - Layout

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (!self.visibleCellsIndexPaths) {
        self.visibleCellsIndexPaths = [NSMutableSet setWithCapacity:self.collectionView.visibleCells.count];
    } else {
        [self.visibleCellsIndexPaths removeAllObjects];
    }
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        [self.visibleCellsIndexPaths addObject:[self.collectionView indexPathForCell:cell]];
    }
    
    NSMutableArray *headerFrames = [NSMutableArray array];
    
    CGSize contentSize = CGSizeZero;
    
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.frame);
    CGFloat cols = [self numberOfColumnsForCurrentSize];
    CGFloat width = (collectionViewWidth - (cols+1)*self.minimumInteritemSpacing)/cols;
    CGSize itemSize = CGSizeMake(width, width);
    
    // first release old item frame sections
    [self clearItemFrames];
    
    // create new item frame sections
    _numberOfItemFrameSections = [self.collectionView numberOfSections];
    
    for (int section = 0; section < [self.collectionView numberOfSections]; section++) {        
        CGSize headerSize = CGSizeMake(self.collectionView.frame.size.width, (self.hideHeader)?0:44);
        
        CGRect headerFrame = CGRectMake(0, contentSize.height, CGRectGetWidth(self.collectionView.bounds), headerSize.height);
        [headerFrames addObject:[NSValue valueWithCGRect:headerFrame]];
        
        CGPoint sectionOffset = CGPointMake(0, contentSize.height + headerSize.height);
        
        CGSize sectionSize = [self setFramesForItemsInSection:section numberOfColumns:cols sectionOffset:sectionOffset itemSize:itemSize];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *headerAttributes = [self.layoutAttributesHeader objectForKey:indexPath];
        if (!headerAttributes) {
            headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
        }
        headerAttributes.frame = headerFrame;
        headerAttributes.zIndex = 100000;
        if (self.hideHeader) {
            headerAttributes.hidden = YES;
        }
        [self.layoutAttributesHeader setObject:headerAttributes forKey:indexPath];
        contentSize = CGSizeMake(sectionSize.width, contentSize.height + headerSize.height + sectionSize.height);
    }
    
    self.headerFrames = [NSArray arrayWithArray:headerFrames];
    
    self.contentSize = contentSize;
}

- (CGSize)setFramesForItemsInSection:(NSInteger)section numberOfColumns:(NSUInteger)numberOfColumns sectionOffset:(CGPoint)sectionOffset itemSize:(CGSize)itemSize
{
    
    CGPoint offset = CGPointMake(sectionOffset.x + self.sectionInset.left + self.minimumInteritemSpacing, sectionOffset.y + self.sectionInset.top);
    
    NSInteger numberOfItemsInSection = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
    
    CGFloat sectionHeight = 0;
    
    for (int j=0; j<numberOfItemsInSection; j++) {
        CGRect f = (CGRect){.origin = CGPointZero, itemSize};
        int row = j/numberOfColumns;
        CGFloat originY = offset.y + row * (itemSize.height + self.minimumLineSpacing);
        int col = j%numberOfColumns;
        CGFloat originX = offset.x + col * (itemSize.width + self.minimumInteritemSpacing);
        f.origin = CGPointMake(originX, originY);
        
        sectionHeight = MAX(sectionHeight, CGRectGetMaxY(f));
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:section];
        [self.itemFrames setObject:[NSValue valueWithCGRect:f] forKey:indexPath];
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attr.frame = f;
        attr.zIndex = 0;
        [self.layoutAttributesIndexPath setObject:attr forKey:indexPath];
    }
    
    
    
    return CGSizeMake(self.collectionView.frame.size.width, sectionHeight - sectionOffset.y);
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.contentSize.width, self.contentSize.height + (self.showLoadingView?LOADING_VIEW_HEIGHT:0));
}

- (CGRect)headerFrameForSection:(NSInteger)section
{
    return [[self.headerFrames objectAtIndex:section] CGRectValue];
}

- (CGRect)itemFrameForIndexPath:(NSIndexPath *)indexPath
{
    return [self.itemFrames[indexPath] CGRectValue];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    for (NSInteger section = 0, n = [self.collectionView numberOfSections]; section < n; section++) {
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        
        UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:sectionIndexPath];
        if (! CGSizeEqualToSize(headerAttributes.frame.size, CGSizeZero) && CGRectIntersectsRect(headerAttributes.frame, rect)) {
            [layoutAttributes addObject:headerAttributes];
        }
        
        for (int i = 0; i < [self.collectionView numberOfItemsInSection:section]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
            CGRect itemFrame = [self itemFrameForIndexPath:indexPath];
            if (CGRectIntersectsRect(rect, itemFrame)) {
                UICollectionViewLayoutAttributes *layoutAttr = [self layoutAttributesForItemAtIndexPath:indexPath];
                layoutAttr.zIndex = 0;
                [layoutAttributes addObject:layoutAttr];
            }
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    if ([self.visibleCellsIndexPaths containsObject:itemIndexPath]) {
        return self.layoutAttributesIndexPath[itemIndexPath];
    }
    
    return nil;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    if ([self.visibleCellsIndexPaths containsObject:itemIndexPath]) {
        return self.layoutAttributesIndexPath[itemIndexPath];
    }
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        attributes = [self.layoutAttributesHeader objectForKey:indexPath];
        [self adjustHeaderLayoutAttributes:attributes];
        attributes.zIndex = 100000;
        if (self.hideHeader) {
            attributes.hidden = YES;
        }
    } else {
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
        attributes.zIndex = 0;

    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = self.layoutAttributesIndexPath[indexPath];
    attr.zIndex = 0;
    return attr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForMissingSectionsHeaders:(NSIndexSet *)missingSections {
    NSMutableArray *headerAttributes = [NSMutableArray array];
    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        
        if (layoutAttributes) [headerAttributes addObject:layoutAttributes];
        
    }];
    return headerAttributes;
}

- (void)adjustHeaderLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    UICollectionView * const cv = self.collectionView;
    
    NSInteger numberOfSections = [cv numberOfSections];
    
    NSInteger section = layoutAttributes.indexPath.section;
    
    CGPoint const contentOffset = cv.contentOffset;
    
    if (section < numberOfSections) {
        // get number of items in the missing header section
        NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];
        
        NSIndexPath *firstObjectIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        NSIndexPath *lastObjectIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
        
        BOOL cellsExist;
        UICollectionViewLayoutAttributes *firstObjectAttrs;
        UICollectionViewLayoutAttributes *lastObjectAttrs;
        
        // get the first and last cell atributes
        if (numberOfItemsInSection > 0) { // use cell data if items exist
            cellsExist = YES;
            firstObjectAttrs = [self layoutAttributesForItemAtIndexPath:firstObjectIndexPath];
            lastObjectAttrs = [self layoutAttributesForItemAtIndexPath:lastObjectIndexPath];
        } else { // else use the header and footer
            cellsExist = NO;
            firstObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                    atIndexPath:firstObjectIndexPath];
            lastObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   atIndexPath:lastObjectIndexPath];
            
        }
        
        CGFloat topHeaderHeight = (cellsExist) ? CGRectGetHeight(layoutAttributes.frame) : 0;
        CGFloat bottomHeaderHeight = CGRectGetHeight(layoutAttributes.frame);
        CGRect frameWithEdgeInsets = UIEdgeInsetsInsetRect(layoutAttributes.frame, cv.contentInset);
        CGPoint origin = frameWithEdgeInsets.origin;
        
        /**
         
         there are three possibilities of header y origin:
         (1) when the section's first item hasn't reached the top of collection view => (CGRectGetMinY(firstObjectAttrs.frame) - topHeaderHeight)
         (2) when the section's first item has crossed the top of collection view, in this case the header should be on the top of collection view =>　contentOffset.y + cv.contentInset.top
         (3) when the section's last item has reached the top of collection view, in this case the header should follow along the last item's position => (CGRectGetMaxY(lastObjectAttrs.frame) - bottomHeaderHeight)
         **/
        origin.y = MIN(
                       MAX(
                           contentOffset.y + cv.contentInset.top - self.topOffsetAdjustment,
                           (CGRectGetMinY(firstObjectAttrs.frame) - topHeaderHeight)
                        ),
                       (CGRectGetMaxY(lastObjectAttrs.frame) - bottomHeaderHeight)
                    );
        
        layoutAttributes.zIndex = 100000;
        layoutAttributes.frame = (CGRect){
            .origin = origin,
            .size = layoutAttributes.frame.size
        };
    }
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    if (self.targetIndexPath) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:self.targetIndexPath];
        self.targetIndexPath = nil;
        return CGPointMake(proposedContentOffset.x, attr.frame.origin.y-44-self.collectionView.contentInset.top);
    }
    return proposedContentOffset;
}

- (NSInteger)numberOfColumnsForCurrentSize {
    if (self.collectionView.frame.size.width < self.collectionView.frame.size.height) {
        return self.numberOfColumns;
    }
    return MAX(self.numberOfColumns * 2 - 1, 1);
}

@end
