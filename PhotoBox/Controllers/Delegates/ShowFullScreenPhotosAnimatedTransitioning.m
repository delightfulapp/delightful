//
//  ShowFullScreenPhotosAnimatedTransitioning.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "ShowFullScreenPhotosAnimatedTransitioning.h"

#import "PhotosHorizontalScrollingViewController.h"
#import "PhotosViewController.h"

@interface ShowFullScreenPhotosAnimatedTransitioning ()

@property (nonatomic, strong) UIImageView *imageViewToAnimate;
@property (nonatomic, strong) UIView *whiteView;

@end

@implementation ShowFullScreenPhotosAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.operation == UINavigationControllerOperationPush) {
        [self animateTransitionForPushOperation:transitionContext];
    } else if (self.operation == UINavigationControllerOperationPop) {
        [self animateTransitionForPopOperation:transitionContext];
    }
}

- (void)animationEnded:(BOOL)transitionCompleted {
    if (transitionCompleted) {
        [self performSelector:@selector(removeHelperViews) withObject:nil afterDelay:1];
    }
    
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

- (void)removeHelperViews {
    [self.imageViewToAnimate removeFromSuperview];
    [self.whiteView removeFromSuperview];
}

- (void)animateTransitionForPushOperation:(id<UIViewControllerContextTransitioning>)transitionContext {
    PhotosViewController *fromVC = (PhotosViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotosHorizontalScrollingViewController *toVC = (PhotosHorizontalScrollingViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSAssert([fromVC conformsToProtocol:@protocol(CustomAnimationTransitionFromViewControllerDelegate)], @"PhotosViewController needs to conform to CustomAnimationTransitionFromViewControllerDelegate");
    
    UIView *containerView = transitionContext.containerView;
    UIImage *image = [fromVC imageToAnimate];
    CGRect startRect = [fromVC startRectInContainerView:containerView];
    
    self.whiteView = [[UIView alloc] initWithFrame:containerView.bounds];
    [self.whiteView setBackgroundColor:[UIColor whiteColor]];
    [self.whiteView setAlpha:0];
    [containerView addSubview:self.whiteView];
    
    self.imageViewToAnimate = [[UIImageView alloc] initWithFrame:startRect];
    [self.imageViewToAnimate setImage:image];
    [containerView addSubview:self.imageViewToAnimate];
    
    [UIView animateWithDuration:[self transitionDuration:nil]/2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.imageViewToAnimate.center = CGPointMake(CGRectGetWidth(containerView.frame)/2, CGRectGetHeight(containerView.frame)/2);
        self.imageViewToAnimate.transform = CGAffineTransformScale(self.imageViewToAnimate.transform, CGRectGetWidth(containerView.frame)/CGRectGetWidth(startRect), CGRectGetWidth(containerView.frame)/CGRectGetWidth(startRect));
        [self.whiteView setAlpha:1];
    } completion:^(BOOL finished) {
        [containerView insertSubview:toVC.view belowSubview:self.imageViewToAnimate];
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateTransitionForPopOperation:(id<UIViewControllerContextTransitioning>)transitionContext {
    PhotosHorizontalScrollingViewController *fromVC = (PhotosHorizontalScrollingViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotosViewController *toVC = (PhotosViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSAssert([fromVC conformsToProtocol:@protocol(CustomAnimationTransitionFromViewControllerDelegate)], @"PhotosHorizontalViewController needs to conform to CustomAnimationTransitionFromViewControllerDelegate");
    
    UIView *containerView = transitionContext.containerView;
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    
    UIView *viewToAnimate = [[fromVC viewToAnimate] snapshotViewAfterScreenUpdates:NO];
    CGRect endRect = [toVC endRectInContainerView:containerView];
    CGRect startRect = [fromVC startRectInContainerView:containerView];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:endRect];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    [containerView addSubview:whiteView];
    
    [containerView addSubview:viewToAnimate];
    [viewToAnimate setFrame:startRect];
    
    [UIView animateWithDuration:[self transitionDuration:nil]/2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [viewToAnimate setFrame:endRect];
        [fromVC.view setAlpha:0];
    } completion:^(BOOL finished) {
        [whiteView removeFromSuperview];
        [viewToAnimate removeFromSuperview];
        [fromVC.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
    
}

@end
