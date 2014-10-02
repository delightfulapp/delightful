//
//  PhotoBoxNavigationControllerDelegate.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "DLFNavigationControllerDelegate.h"

#import "PhotosHorizontalScrollingViewController.h"
#import "PhotosViewController.h"

#import "ShowFullScreenPhotosAnimatedTransitioning.h"

@implementation DLFNavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    ShowFullScreenPhotosAnimatedTransitioning *transitioning = [[ShowFullScreenPhotosAnimatedTransitioning alloc] init];
    transitioning.operation = operation;
    if (([fromVC isKindOfClass:[PhotosViewController class]] && [toVC isKindOfClass:[PhotosHorizontalScrollingViewController class]] && operation==UINavigationControllerOperationPush) || ([fromVC isKindOfClass:[PhotosHorizontalScrollingViewController class]] && [toVC isKindOfClass:[PhotosViewController class]] && operation==UINavigationControllerOperationPop)) {
        return transitioning;
    }
    return nil;
}

@end
