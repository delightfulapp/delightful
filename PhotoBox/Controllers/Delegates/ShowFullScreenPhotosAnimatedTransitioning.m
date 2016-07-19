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
    PBX_LOG(@"Animate push transition");
    
    [self removeHelperViews];
    
    UIViewController *fromVCContainer = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotosViewController *fromVC = (PhotosViewController *)self.presentingViewController;
    
    UIViewController *toVCContainer = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    PhotosHorizontalScrollingViewController *toVC;
    if ([toVCContainer isKindOfClass:[UINavigationController class]]) {
        toVC = (PhotosHorizontalScrollingViewController *)(((UINavigationController *)toVCContainer).topViewController);
    } else {
        toVC = (PhotosHorizontalScrollingViewController *)toVCContainer;
    }
    
    UIView *containerView = transitionContext.containerView;
    
    UIImage *image = [fromVC imageToAnimate];
    CGRect startRect = [fromVC startRectInContainerView:fromVCContainer.view];
    
    self.whiteView = [[UIView alloc] initWithFrame:containerView.bounds];
    [self.whiteView setBackgroundColor:[UIColor whiteColor]];
    [self.whiteView setAlpha:0];
    [containerView addSubview:self.whiteView];
    
    self.imageViewToAnimate = [[UIImageViewModeScaleAspect alloc] initWithFrame:startRect];
    [self.imageViewToAnimate setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageViewToAnimate setTag:ANIMATED_IMAGE_VIEW_ON_PUSH_TAG];
    [self.imageViewToAnimate setImage:image];
    [self.imageViewToAnimate initToScaleAspectFitToFrame:CGRectMake(0, 0, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame))];
    
    [toVCContainer.view setAlpha:0];
    [toVC.view setAlpha:0];
    [containerView insertSubview:toVCContainer.view aboveSubview:self.whiteView];
    
    [containerView insertSubview:self.imageViewToAnimate belowSubview:toVCContainer.view];
    
    [UIView animateWithDuration:[self transitionDuration:nil]
                          delay:0 usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        [self.imageViewToAnimate animaticToScaleAspectFit];
        
        [self.whiteView setAlpha:1];
    } completion:^(BOOL finished) {
        [toVCContainer.view setAlpha:1];
        [toVC.view setAlpha:1];
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateTransitionForPopOperation:(id<UIViewControllerContextTransitioning>)transitionContext {
    PBX_LOG(@"Animate pop transition");
    
    UIViewController *fromVCContainer = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotosHorizontalScrollingViewController *fromVC;
    if ([fromVCContainer isKindOfClass:[UINavigationController class]]) {
        fromVC = (PhotosHorizontalScrollingViewController *)(((UINavigationController *)fromVCContainer).topViewController);
    } else {
        fromVC = (PhotosHorizontalScrollingViewController *)fromVCContainer;
    }
    PhotosViewController *toVC = (PhotosViewController *)self.presentingViewController;
    
    NSAssert([fromVC conformsToProtocol:@protocol(CustomAnimationTransitionFromViewControllerDelegate)], @"PhotosHorizontalViewController needs to conform to CustomAnimationTransitionFromViewControllerDelegate");
    
    // get the container view where the animation will happen
    UIView *containerView = transitionContext.containerView;
    
    // the rect of the image view in photos view controller
    CGRect endRect = [toVC endRectInContainerView:containerView];
    
    // white view to hide the image in photos view controller
    UIView *destinationView = [toVC destinationViewOnDismiss];
    UIView *whiteView = [[UIView alloc] initWithFrame:destinationView.bounds];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    [destinationView addSubview:whiteView];
    
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
    [containerView insertSubview:viewToAnimate belowSubview:fromVCContainer.view];
    
    // set the frame of the image view in container's view coordinate
    [viewToAnimate setFrame:inContainerViewRect];
    
    // start the animation. numbers are selected after trial and error.
    [UIView animateWithDuration:[self transitionDuration:nil] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.9 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [viewToAnimate setFrame:endRect];
        [fromVCContainer.view setAlpha:0];
    } completion:^(BOOL finished) {
        [whiteView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end
