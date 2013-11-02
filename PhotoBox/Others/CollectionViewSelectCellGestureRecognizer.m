//
//  CollectionViewSelectCellGestureRecognizer.m
//  PhotoBox
//
//  Created by Nico Prananta on 11/2/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "CollectionViewSelectCellGestureRecognizer.h"

@interface CollectionViewSelectCellGestureRecognizer () <UIGestureRecognizerDelegate> {
    CGRect selectionRect;
    BOOL continueScrolling;
    BOOL isTimerRunning;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSMutableArray *selectedIndexPaths;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) NSTimer *scrollingTimer;

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

- (NSTimer *)scrollingTimer {
    if (!_scrollingTimer) {
        _scrollingTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(continuouslyScrollCollectionView) userInfo:nil repeats:YES];
    }
    return _scrollingTimer;
}

#pragma mark - Collection View

- (void)continuouslyScrollCollectionView {
    if (continueScrolling) {
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + 50) animated:YES];
        [self updateSelectionRectWithTouchPoint:[self.panGesture locationInView:self.collectionView]];
        [self toggleSelectedStateOfVisibleCellsInRect:selectionRect];
    } else {
        [self.scrollingTimer invalidate];
        self.scrollingTimer = nil;
        isTimerRunning = NO;
    }
}

#pragma mark - Pan Gesture

- (void)collectionViewPanned:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Gesture began: %@", NSStringFromCGPoint([gesture locationInView:self.collectionView]));
            CGPoint initPoint = [gesture locationInView:self.collectionView];
            selectionRect = CGRectMake(initPoint.x, initPoint.y, 0, 0);
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"Gesture changed %@. Collection view size = %@", NSStringFromCGPoint([gesture locationInView:self.collectionView.superview]), NSStringFromCGSize(self.collectionView.frame.size));
            if ([gesture locationInView:self.collectionView.superview].y >= CGRectGetHeight(self.collectionView.frame) - 50) {
                continueScrolling = YES;
                if (!isTimerRunning) {
                    NSLog(@"Are we here?");
                    [[NSRunLoop currentRunLoop] addTimer:self.scrollingTimer forMode:NSRunLoopCommonModes];
                    isTimerRunning = YES;
                }
            } else {
                continueScrolling = NO;
            }
            [self updateSelectionRectWithTouchPoint:[gesture locationInView:self.collectionView]];
            [self toggleSelectedStateOfVisibleCellsInRect:selectionRect];
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

- (void)updateSelectionRectWithTouchPoint:(CGPoint)point {
    selectionRect = ({
        selectionRect.size = CGSizeMake(point.x - selectionRect.origin.x, point.y - selectionRect.origin.y);
        selectionRect;
    });
}

- (void)toggleSelectedStateOfVisibleCellsInRect:(CGRect)rect {
    NSArray *visibleCells = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in visibleCells) {
        if (CGRectIntersectsRect(rect, cell.frame)) {
            [cell setSelected:YES];
        } else {
            [cell setSelected:NO];
        }
    }
}

#pragma mark - Gesture delegate

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
