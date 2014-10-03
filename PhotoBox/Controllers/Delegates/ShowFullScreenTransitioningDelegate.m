//
//  ShowFullScreenTransitioningDelegate.m
//  Delightful
//
//  Created by  on 10/3/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "ShowFullScreenTransitioningDelegate.h"

#import "ShowFullScreenPhotosAnimatedTransitioning.h"

@interface ShowFullScreenPresentationController : UIPresentationController

@end

@interface ShowFullScreenTransitioningDelegate () <UIAdaptivePresentationControllerDelegate>

@end

@implementation ShowFullScreenTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    ShowFullScreenPresentationController *presentationController = [[ShowFullScreenPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return presentationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    ShowFullScreenPhotosAnimatedTransitioning *showFullScreenAnimated = [[ShowFullScreenPhotosAnimatedTransitioning alloc] init];
    [showFullScreenAnimated setOperation:UINavigationControllerOperationPush];
    return showFullScreenAnimated;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    ShowFullScreenPhotosAnimatedTransitioning *showFullScreenAnimated = [[ShowFullScreenPhotosAnimatedTransitioning alloc] init];
    [showFullScreenAnimated setOperation:UINavigationControllerOperationPop];
    return showFullScreenAnimated;
}

@end

@implementation ShowFullScreenPresentationController

- (BOOL)shouldRemovePresentersView {
    NSLog(@"should remove presenter view");
    return NO;
}

@end