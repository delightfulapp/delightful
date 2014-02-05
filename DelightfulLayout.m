//
//  DelightfulLayout.m
//  Delightful
//
//  Created by Nico Prananta on 2/4/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DelightfulLayout.h"

@interface DelightfulLayout ()

@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@end

@implementation DelightfulLayout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath];
    if (self.showLoadingView && self.lastIndexPath) {
        [self adjustLayoutAttribute:attr];
    }
    return attr;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    if (self.showLoadingView && self.lastIndexPath) {
        for (UICollectionViewLayoutAttributes *attr in attributes) {
            [self adjustLayoutAttribute:attr];
        }
    }
    
    return attributes;
}

- (void)adjustLayoutAttribute:(UICollectionViewLayoutAttributes *)attr {
    if (![attr.indexPath isEqual:self.lastIndexPath] && ![self isInTheSameRowIndexPath:attr.indexPath withIndexPath:self.lastIndexPath] && [attr.indexPath compare:self.lastIndexPath] == NSOrderedDescending) {
        attr.frame = CGRectOffset(attr.frame, 0, LOADING_VIEW_HEIGHT);
    }
}

- (BOOL)isInTheSameRowIndexPath:(NSIndexPath *)indexPath withIndexPath:(NSIndexPath *)indexPath2 {
    if (indexPath.section != indexPath2.section) {
        return NO;
    } else {
        NSInteger row1 = indexPath.item/self.numberOfColumns;
        NSInteger row2 = indexPath2.item/self.numberOfColumns;
        return row1==row2;
    }
}

- (void)setShowLoadingView:(BOOL)showLoadingView {
    _showLoadingView = showLoadingView;
    
    if (!_showLoadingView) {
        self.lastIndexPath = nil;
    }
}

- (void)updateLastIndexPath {
    NSInteger lastSection = NSIntegerMin;
    NSInteger lastItemIndexInLastSection = NSIntegerMin;
    if (self.collectionView.numberOfSections > 0) {
        lastSection = self.collectionView.numberOfSections - 1;
        if ([self.collectionView numberOfItemsInSection:lastSection] > 0) {
            lastItemIndexInLastSection = [self.collectionView numberOfItemsInSection:lastSection]-1;
        }
    }
    self.lastIndexPath = [NSIndexPath indexPathForRow:lastItemIndexInLastSection inSection:lastSection];
}

@end
