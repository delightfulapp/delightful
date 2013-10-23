//
//  UIWindow+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIWindow+Additionals.h"

@implementation UIWindow (Additionals)

+ (UIViewController *)rootViewController {
    return [[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

+ (UIViewController *)topMostViewController {
    UIViewController *root = [UIWindow rootViewController];
    if ([root isKindOfClass:[UINavigationController class]]) {
        root = ((UINavigationController *)root).visibleViewController;
    }
    return root;
}

@end
