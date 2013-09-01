//
//  PhotoBoxNavigationControllerDelegate.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxNavigationControllerDelegate.h"

#import "PhotosHorizontalScrollingViewController.h"
#import "PhotosViewController.h"

#import "ShowFullScreenPhotosAnimatedTransitioning.h"

@implementation PhotoBoxNavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if ([fromVC isKindOfClass:[PhotosViewController class]] && [toVC isKindOfClass:[PhotosHorizontalScrollingViewController class]] && operation==UINavigationControllerOperationPush) {
        NSLog(@"Show full screen photos animated transitioning");
        ShowFullScreenPhotosAnimatedTransitioning *transitioning = [[ShowFullScreenPhotosAnimatedTransitioning alloc] init];
        return transitioning;
    }
    return nil;
}

@end
