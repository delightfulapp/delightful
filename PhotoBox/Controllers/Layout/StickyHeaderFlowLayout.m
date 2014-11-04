//
//  StickyHeaderFlowLayout.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "StickyHeaderFlowLayout.h"

@interface StickyHeaderFlowLayout ()

@property (nonatomic, strong) NSMutableArray *insertIndexPaths;

@end

@implementation StickyHeaderFlowLayout


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    //CLS_LOG(@"Layout attributes in rect %@", NSStringFromCGRect(rect));
    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    NSIndexSet *missingSections = [self missingSectionsForAttributes:answer];
    
    [answer addObjectsFromArray:[self layoutAttributesForMissingSectionsHeaders:missingSections]];
    
    // for each attributes including the missing header section's attribute
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        
        // if the attribute is header
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [self adjustHeaderLayoutAttributes:layoutAttributes];
        }  else {
            layoutAttributes.zIndex = 0;
        }
    }
    
    return answer;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        [self adjustHeaderLayoutAttributes:attr];
    } else {
        //CLS_LOG(@"Layout attributes for footer at %d-%d = %@", (int)indexPath.section, (int)indexPath.row, attr);
        if (!attr) {
            attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
        }
    }
    
    return attr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    //CLS_LOG(@"Attributes at index %d-%d", (int)indexPath.section, (int)indexPath.item);
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath];
    attr.zIndex = 0;
    return attr;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}

- (NSIndexSet *)missingSectionsForAttributes:(NSArray *)answer {
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    
    // add visible sections to missingSections
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [missingSections addIndex:layoutAttributes.indexPath.section];
        }
    }
    // remove visible section with header showing. it will leave us with only sections without visible header
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [missingSections removeIndex:layoutAttributes.indexPath.section];
        }
    }
    return missingSections;
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

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    // Keep track of insert and delete index paths
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionInsert)
        {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    // release the insert and delete index paths
    self.insertIndexPaths = nil;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    if (self.targetIndexPath) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:self.targetIndexPath];
        return CGPointMake(proposedContentOffset.x, attr.frame.origin.y-44-self.collectionView.contentInset.top);
    }
    return proposedContentOffset;
}

@end
