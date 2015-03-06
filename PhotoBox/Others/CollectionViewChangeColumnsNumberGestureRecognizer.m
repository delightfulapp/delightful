//
//  CollectionViewChangeColumnsNumberGestureRecognizer.m
//  Delightful
//
//  Created by  on 2/11/15.
//  Copyright (c) 2015 Touches. All rights reserved.
//

#import "CollectionViewChangeColumnsNumberGestureRecognizer.h"
#import "CollectionViewLayoutOffsetDelegate.h"

typedef NS_ENUM(NSUInteger, PinchDirection) {
    PinchIn,
    PinchOut
};

@interface CollectionViewChangeColumnsNumberGestureRecognizer ()

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSString *numberOfColumnsKey;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

@end

@implementation CollectionViewChangeColumnsNumberGestureRecognizer

- (id)initWithCollectionView:(UICollectionView *)collectionView numberOfColumnsKey:(NSString *)numberOfColumnsKey{
    self = [super init];
    if (self) {
        NSAssert([collectionView.collectionViewLayout respondsToSelector:NSSelectorFromString(numberOfColumnsKey)], @"Collection view layout must have %@ property.", numberOfColumnsKey);
        _collectionView = collectionView;
        _numberOfColumnsKey = numberOfColumnsKey;
        _enableGesture = YES;
        [self setup];
    }
    return self;
}

- (void)setup {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewPinched:)];
    [self.collectionView addGestureRecognizer:pinch];
    self.pinchGestureRecognizer = pinch;
}

- (void)setEnableGesture:(BOOL)enableGesture {
    if (_enableGesture != enableGesture) {
        _enableGesture = enableGesture;
        
        [self.pinchGestureRecognizer setEnabled:_enableGesture];
    }
}

- (NSInteger)numberOfColumnsInCollectionView {
    return [[self.collectionView.collectionViewLayout valueForKey:self.numberOfColumnsKey] integerValue];
}

#pragma mark - Gesture

- (void)collectionViewPinched:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (gesture.scale > 1) {
            [self changeNumberOfColumnsWithPinch:PinchOut];
        } else {
            [self changeNumberOfColumnsWithPinch:PinchIn];
        }
    }
}

- (void)changeNumberOfColumnsWithPinch:(PinchDirection)direction {
    int numCol = (int)[self numberOfColumnsInCollectionView];
    int currentNumCol = numCol;
    switch (direction) {
        case PinchIn:{
            numCol = MIN(++numCol, 10);
            break;
        }
        case PinchOut:{
            numCol = MAX(--numCol, 1);
            break;
        }
        default:
            break;
    }
    if (numCol != currentNumCol) {
        [self.collectionView.collectionViewLayout setValue:@(numCol) forKey:self.numberOfColumnsKey];
        
        NSArray *visibleCells = [self.collectionView visibleCells];
        if (visibleCells && visibleCells.count > 0) {
            
            NSIndexPath *indexPath;
            CGFloat minimumVisibleY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
            for (UICollectionViewCell *cell in visibleCells) {
                if (cell.frame.origin.y > minimumVisibleY) {
                    if (!indexPath) {
                        indexPath = [self.collectionView indexPathForCell:cell];
                    } else {
                        NSIndexPath *thisIndexPath = [self.collectionView indexPathForCell:cell];
                        NSComparisonResult result = [thisIndexPath compare:indexPath];
                        if (result == NSOrderedAscending) {
                            indexPath = thisIndexPath;
                        }
                    }
                }
            }
            if ([self.collectionView.collectionViewLayout respondsToSelector:@selector(targetIndexPath)]) {
                [((id)self.collectionView.collectionViewLayout) setTargetIndexPath:indexPath];
            }
            
            [self.collectionView performBatchUpdates:^{
            } completion:^(BOOL finished) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeNumberOfColumns:)]) {
                    [self.delegate didChangeNumberOfColumns:numCol];
                }
            }];
        }
    }
}

@end
