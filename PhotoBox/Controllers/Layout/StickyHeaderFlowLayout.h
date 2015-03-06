//
//  StickyHeaderFlowLayout.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewLayoutOffsetDelegate.h"

#define LOADING_VIEW_HEIGHT 50

@interface StickyHeaderFlowLayout : UICollectionViewFlowLayout <CollectionViewLayoutOffsetDelegate>

- (void)adjustHeaderLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes;

@property (nonatomic, assign) CGFloat topOffsetAdjustment;
@property (nonatomic, strong) NSIndexPath *targetIndexPath;
@property (nonatomic, assign) BOOL showLoadingView;
@property (nonatomic, assign) NSInteger numberOfColumns;
@property (nonatomic, assign) BOOL hideHeader;

@end
