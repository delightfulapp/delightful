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

#define ANIMATED_IMAGE_VIEW_ON_PUSH_TAG 456812

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
    [self performSelector:@selector( removeHelperViews) withObject:nil afterDelay:0.5];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)removeHelperViews {
    [self.imageViewToAnimate removeFromSuperview];
    [self.whiteView removeFromSuperview];
}

- (void)animateTransitionForPushOperation:(id<UIViewControllerContextTransitioning>)transitionContext {
    [self removeHelperViews];
    
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
    [self.imageViewToAnimate setTag:ANIMATED_IMAGE_VIEW_ON_PUSH_TAG];
    [self.imageViewToAnimate setImage:image];
    [containerView addSubview:self.imageViewToAnimate];
    
    [UIView animateWithDuration:[self transitionDuration:nil] delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.imageViewToAnimate.center = CGPointMake(CGRectGetWidth(containerView.frame)/2, CGRectGetHeight(containerView.frame)/2);
        self.imageViewToAnimate.transform = CGAffineTransformScale(self.imageViewToAnimate.transform, CGRectGetWidth(containerView.frame)/CGRectGetWidth(startRect), CGRectGetWidth(containerView.frame)/CGRectGetWidth(startRect));
        [self.whiteView setAlpha:1];
    } completion:^(BOOL finished) {
        [containerView insertSubview:toVC.view belowSubview:self.whiteView];
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateTransitionForPopOperation:(id<UIViewControllerContextTransitioning>)transitionContext {
    PhotosHorizontalScrollingViewController *fromVC = (PhotosHorizontalScrollingViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotosViewController *toVC = (PhotosViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSAssert([fromVC conformsToProtocol:@protocol(CustomAnimationTransitionFromViewControllerDelegate)], @"PhotosHorizontalViewController needs to conform to CustomAnimationTransitionFromViewControllerDelegate");
    
    UIView *containerView = transitionContext.containerView;
    
    // when push and pop quickly, there still the image view from push
    UIView *animatedImageViewOnPush = [containerView viewWithTag:ANIMATED_IMAGE_VIEW_ON_PUSH_TAG];
    [animatedImageViewOnPush removeFromSuperview];
    
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    
    CGRect endRect = [toVC endRectInContainerView:containerView];
    CGRect startRect = [fromVC startRectInContainerView:containerView];
    
    UIView *viewToAnimate = [fromVC viewToAnimate];
    
    UIGraphicsBeginImageContext(viewToAnimate.frame.size);
    [viewToAnimate.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], startRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIImageView *screenshotImage = [[UIImageView alloc] initWithImage:result];
    [screenshotImage setFrame:startRect];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:endRect];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    
    [containerView addSubview:whiteView];
    
    [containerView addSubview:screenshotImage];
    
    [UIView animateWithDuration:[self transitionDuration:nil] delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [screenshotImage setFrame:endRect];
        [fromVC.view setAlpha:0];
    } completion:^(BOOL finished) {
        [whiteView removeFromSuperview];
        [screenshotImage removeFromSuperview];
        [fromVC.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
    
}

@end
