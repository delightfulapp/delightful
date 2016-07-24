//
//  TransitionToInfoDelegate.m
//  Delightful
//
//  Created by  on 10/4/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "TransitionToInfoDelegate.h"

#import "TransitionToInfoPresentationController.h"

@implementation TransitionToInfoDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    TransitionToInfoPresentationController *pc = [[TransitionToInfoPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return pc;
}

@end
