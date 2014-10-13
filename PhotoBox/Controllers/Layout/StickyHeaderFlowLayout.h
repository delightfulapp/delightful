//
//  StickyHeaderFlowLayout.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "DelightfulLayout.h"

@interface StickyHeaderFlowLayout : DelightfulLayout

- (void)adjustHeaderLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes;

@property (nonatomic, assign) CGFloat topOffsetAdjustment;

@property (nonatomic, strong) NSIndexPath *targetIndexPath;

@end
