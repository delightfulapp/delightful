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
#import "UIView+Additionals.h"
#import "UIImage+Additionals.h"

#import "UIImageViewModeScaleAspect.h"

#define ANIMATED_IMAGE_VIEW_ON_PUSH_TAG 456812

@interface ShowFullScreenPhotosAnimatedTransitioning ()

@property (nonatomic, strong) UIImageViewModeScaleAspect *imageViewToAnimate;
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
    [self removeHelperViews];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)removeHelperViews {
    [self.imageViewToAnimate removeFromSuperview];
    [self.whiteView removeFromSuperview];
}

- (void)animateTransitionForPushOperation:(id<UIViewControllerContextTransitioning>)transitionContext {
    CLS_LOG(@"Animate push transition");
    
    [self removeHelperViews];
    
    PhotosViewController *fromVC = (PhotosViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotosHorizontalScrollingViewController *toVC = (PhotosHorizontalScrollingViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    UIImage *image = [fromVC imageToAnimate];
    CGRect startRect = [fromVC startRectInContainerView:containerView];
    
    self.whiteView = [[UIView alloc] initWithFrame:containerView.bounds];
    [self.whiteView setBackgroundColor:[UIColor whiteColor]];
    [self.whiteView setAlpha:0];
    [containerView addSubview:self.whiteView];
    
    self.imageViewToAnimate = [[UIImageViewModeScaleAspect alloc] initWithFrame:startRect];
    [self.imageViewToAnimate setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageViewToAnimate setTag:ANIMATED_IMAGE_VIEW_ON_PUSH_TAG];
    [self.imageViewToAnimate setImage:image];
    [self.imageViewToAnimate initToScaleAspectFitToFrame:CGRectMake(0, 0, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame))];
    
    [containerView addSubview:self.imageViewToAnimate];
    
    [UIView animateWithDuration:[self transitionDuration:nil] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.imageViewToAnimate animaticToScaleAspectFit];
        [self.whiteView setAlpha:1];
    } completion:^(BOOL finished) {
        [containerView insertSubview:toVC.view belowSubview:self.whiteView];
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateTransitionForPopOperation:(id<UIViewControllerContextTransitioning>)transitionContext {
    CLS_LOG(@"Animate pop transition");
    
    PhotosHorizontalScrollingViewController *fromVC = (PhotosHorizontalScrollingViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotosViewController *toVC = (PhotosViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSAssert([fromVC conformsToProtocol:@protocol(CustomAnimationTransitionFromViewControllerDelegate)], @"PhotosHorizontalViewController needs to conform to CustomAnimationTransitionFromViewControllerDelegate");
    
    // get the container view where the animation will happen
    UIView *containerView = transitionContext.containerView;
    
    // when push and pop quickly, there still the image view from push
    UIView *animatedImageViewOnPush = [containerView viewWithTag:ANIMATED_IMAGE_VIEW_ON_PUSH_TAG];
    [animatedImageViewOnPush removeFromSuperview];
    
    // put the destination view controller's view under the starting view controller's view
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    
    // the rect of the image view in photos view controller
    CGRect endRect = [toVC endRectInContainerView:containerView];
    
    // white view to hide the image in photos view controller
    UIView *whiteView = [[UIView alloc] initWithFrame:endRect];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    [containerView addSubview:whiteView];
    
    // the view to animate which is the image view inside the scroll view of PhotoZoomableCell
    UIImageView *viewToAnimate = (UIImageView *)[fromVC viewToAnimate];
    [viewToAnimate setContentMode:UIViewContentModeScaleAspectFill];
    [viewToAnimate setClipsToBounds:YES];
    
    // get the rect of the image view in containerView's coordinate
    CGRect inContainerViewRect = [viewToAnimate convertRect:viewToAnimate.bounds toView:containerView];
    
    // set zoom scale to 1 to get the original frame/bounds of image view
    UIScrollView *scrollView = (UIScrollView *)[viewToAnimate superview];
    [scrollView setZoomScale:1];
    
    // remove the image view from scroll view then move it to containerView
    [viewToAnimate removeFromSuperview];
    [containerView addSubview:viewToAnimate];
    
    // set the frame of the image view in container's view coordinate
    [viewToAnimate setFrame:inContainerViewRect];
    
    // start the animation
    [UIView animateWithDuration:[self transitionDuration:nil] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
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
