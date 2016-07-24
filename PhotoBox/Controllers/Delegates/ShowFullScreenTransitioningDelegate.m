//
//  ShowFullScreenTransitioningDelegate.m
//  Delightful
//
//  Created by  on 10/3/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "ShowFullScreenTransitioningDelegate.h"

#import "ShowFullScreenPhotosAnimatedTransitioning.h"

@interface ShowFullScreenPresentationController : UIPresentationController

@property (nonatomic, assign) BOOL isPresenting;

@end

@interface ShowFullScreenTransitioningDelegate () 

@property (nonatomic, strong) ShowFullScreenPresentationController *presentationController;

@property (nonatomic, strong) UIViewController *sourceViewController;

@end

@implementation ShowFullScreenTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    self.sourceViewController = source;
    self.presentationController = [[ShowFullScreenPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return self.presentationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    ShowFullScreenPhotosAnimatedTransitioning *showFullScreenAnimated = [[ShowFullScreenPhotosAnimatedTransitioning alloc] init];
    [showFullScreenAnimated setPresentingViewController:(id)source];
    [showFullScreenAnimated setOperation:UINavigationControllerOperationPush];
    [self.presentationController setIsPresenting:YES];
    return showFullScreenAnimated;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    ShowFullScreenPhotosAnimatedTransitioning *showFullScreenAnimated = [[ShowFullScreenPhotosAnimatedTransitioning alloc] init];
    [showFullScreenAnimated setOperation:UINavigationControllerOperationPop];
    [showFullScreenAnimated setPresentingViewController:self.sourceViewController];
    [self.presentationController setIsPresenting:NO];
    return showFullScreenAnimated;
}

@end

@implementation ShowFullScreenPresentationController

- (BOOL)shouldRemovePresentersView {
    return NO;
}

@end
