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
    UITabBarController *tabBarController = (UITabBarController *)[UIWindow rootViewController];
    UIViewController *viewController = [tabBarController selectedViewController];
    return viewController;
}

+ (UIWindow *)appWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

@end
