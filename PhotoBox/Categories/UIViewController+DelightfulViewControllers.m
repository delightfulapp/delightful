//
//  UIViewController+DelightfulViewControllers.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIViewController+DelightfulViewControllers.h"

#import <JASidePanelController.h>

#import "AppDelegate.h"

@implementation UIViewController (DelightfulViewControllers)

+ (id)mainPhotosViewController {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    JASidePanelController *rootViewController = (JASidePanelController *)delegate.window.rootViewController;
    UINavigationController *centerController = (UINavigationController *)rootViewController.centerPanel;
    return centerController.viewControllers[0];
}

+ (id)panelViewController {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    JASidePanelController *rootViewController = (JASidePanelController *)delegate.window.rootViewController;
    NSAssert(rootViewController, @"wtf?");
    return rootViewController;
}

+ (CGFloat)leftViewControllerVisibleWidth {
    JASidePanelController *sidePanel = [[self class] panelViewController];
    return sidePanel.leftVisibleWidth;
}

+ (id)leftViewController {
    JASidePanelController *sidePanel = [[self class] panelViewController];
    return sidePanel.leftPanel;
}

@end
