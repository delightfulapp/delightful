//
//  TransitionToInfoPresentationController.m
//  Delightful
//
//  Created by  on 10/4/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "TransitionToInfoPresentationController.h"

#import "UIView+Additionals.h"

@interface TransitionToInfoPresentationController ()

@property (nonatomic, weak) UIView *gradientView;

@end

@implementation TransitionToInfoPresentationController

- (void)presentationTransitionWillBegin {
    UIView *containerView = [self containerView];
    UIView *gradientView = [containerView addTransparentGradientWithStartColor:[UIColor blackColor] fromStartPoint:CGPointMake(0, 1) endPoint:CGPointMake(0.7, 0.5)];
    [gradientView setAlpha:0];
    self.gradientView = gradientView;
    
    
    id presentingVC = [self presentingViewController];
    if ([presentingVC isKindOfClass:[UINavigationController class]]) {
        presentingVC = [presentingVC topViewController];
    }
    if ([presentingVC respondsToSelector:@selector(willAnimateAlongTransitionToPresentInfoController:)]) {
        [presentingVC willAnimateAlongTransitionToPresentInfoController:self];
    }
    if ([presentingVC respondsToSelector:@selector(animateAlongTransitionToPresentInfoController:)]) {
        [gradientView setAlpha:1];
        [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [presentingVC animateAlongTransitionToPresentInfoController:self];
        } completion:nil];
    }
}

- (void)dismissalTransitionWillBegin {
    id presentingVC = [self presentingViewController];
    if ([presentingVC isKindOfClass:[UINavigationController class]]) {
        presentingVC = [presentingVC topViewController];
    }
    [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.gradientView setAlpha:0];
        if ([presentingVC respondsToSelector:@selector(dismissAlongTransitionToInfoController:)]) {
            [presentingVC dismissAlongTransitionToInfoController:self];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.gradientView removeFromSuperview];
        self.gradientView = nil;
        if ([presentingVC respondsToSelector:@selector(didFinishDismissAnimationFromInfoControllerPresentationController:)]) {
            [presentingVC didFinishDismissAnimationFromInfoControllerPresentationController:self];
        }
    }];
    
}

- (BOOL)shouldRemovePresentersView {
    return NO;
}

@end
