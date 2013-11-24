//
//  UIWindow+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIWindow+Additionals.h"

#import "PanelsContainerViewController.h"

@implementation UIWindow (Additionals)

+ (UIViewController *)rootViewController {
    return [[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

+ (UIViewController *)topMostViewController {
    id topMostViewController;
    PanelsContainerViewController *root = (PanelsContainerViewController *)[UIWindow rootViewController];
    UINavigationController *rootNavigationController = (UINavigationController *)root.centerPanel;
    if ([rootNavigationController isKindOfClass:[UINavigationController class]]) {
        topMostViewController = ((UINavigationController *)rootNavigationController).viewControllers[0];
    }
    return topMostViewController;
}

+ (UIWindow *)appWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

@end
