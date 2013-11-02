//
//  CollectionViewSelectCellGestureRecognizer.m
//  PhotoBox
//
//  Created by Nico Prananta on 11/2/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "CollectionViewSelectCellGestureRecognizer.h"

@interface CollectionViewSelectCellGestureRecognizer () <UIGestureRecognizerDelegate> {
    CGPoint initialPoint;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSMutableArray *selectedIndexPaths;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation CollectionViewSelectCellGestureRecognizer

- (id)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    
    if (self) {
        _collectionView = collectionView;
        _enable = YES;
        _selectedIndexPaths = [NSMutableArray array];
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewPanned:)];
        [_panGesture setDelegate:self];
        [_collectionView addGestureRecognizer:_panGesture];
    }
    
    return self;
}

- (void)cancelSelection {
    @synchronized(self){
        [self.selectedIndexPaths removeAllObjects];
    }
}

- (BOOL)isSelecting {
    @synchronized(self) {
        return self.selectedIndexPaths.count==0?NO:YES;
    }
}

#pragma mark - Pan Gesture

- (void)collectionViewPanned:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Gesture began: %@", NSStringFromCGPoint([gesture locationInView:self.collectionView]));
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"Gesture changed: %@", NSStringFromCGPoint([gesture translationInView:self.collectionView]));
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"Gesture cancelled");
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Gesture ended");
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"Gesture failed");
            break;
        case UIGestureRecognizerStatePossible:
            NSLog(@"Gesture possible");
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [gestureRecognizer velocityInView:self.collectionView];
    if (velocity.y < 10 && velocity.x > 10) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
