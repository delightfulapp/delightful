//
//  FallingTransitioningDelegate.m
//  Delightful
//
//  Created by Nico Prananta on 5/24/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "FallingTransitioningDelegate.h"

@interface FallingTransitioningDelegate () <UIViewControllerAnimatedTransitioning, UIDynamicAnimatorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, assign) BOOL isPresentingTransition;

@property (nonatomic, assign) CGRect endFrame;

@end

@implementation FallingTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.isPresentingTransition = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.isPresentingTransition = NO;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
        
    toVC.view.frame = containerView.bounds;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:containerView];
    
    [self.animator setDelegate:self];
    
    UICollisionBehavior* collisionBehavior;
    
    if (self.isPresentingTransition) {
        [containerView addSubview:toVC.view];
        
        toVC.view.frame = CGRectOffset(containerView.bounds, 0, -CGRectGetHeight(toVC.view.frame)-100);
        
        UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[toVC.view]];
        [gravityBehavior setGravityDirection:CGVectorMake(0, self.speed)];
        [self.animator addBehavior:gravityBehavior];
        
        collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[toVC.view]];
        collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
        [collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-2*CGRectGetHeight(containerView.frame), 0, 0, 0)];
        [self.animator addBehavior:collisionBehavior];
    } else {
        UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[fromVC.view]];
        gravityBehaviour.gravityDirection = CGVectorMake(0, 10);
        [self.animator addBehavior:gravityBehaviour];
        
        UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[fromVC.view]];
        [itemBehaviour addAngularVelocity:-M_PI_2 forItem:fromVC.view];
        [self.animator addBehavior:itemBehaviour];
    }
    
    [self ensureSimulationCompletesWithDesiredEndFrame:containerView.bounds];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    UIViewController *toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [self.animator removeAllBehaviors];
    
    if (self.isPresentingTransition) {
        toViewController.view.frame = self.endFrame;
        
        // some weird bug where navigation bar changes its origin to 0 that makes it covered by status bar.
        if (self.speed > 3) {
            if ([toViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navCon = (UINavigationController *)toViewController;
                if (![[UIApplication sharedApplication] isStatusBarHidden]) {
                    navCon.navigationBar.frame = ({
                        CGRect frame = navCon.navigationBar.frame;
                        frame.size.height += CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
                        frame;
                    });
                }
            }
        }
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    CLS_LOG(@"context complete");
}

-(void)ensureSimulationCompletesWithDesiredEndFrame:(CGRect)endFrame {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    self.endFrame = endFrame;
    
    double delayInSeconds = [self transitionDuration:self.transitionContext];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        id<UIViewControllerContextTransitioning> blockContext = self.transitionContext;
        UIDynamicAnimator *blockAnimator = self.animator;
        if (blockAnimator && blockContext == transitionContext) {
            [transitionContext completeTransition:YES];
        }
    });
}

- (NSInteger)speed {
    if (_speed == 0) {
        _speed = 3;
    }
    return _speed;
}

@end
