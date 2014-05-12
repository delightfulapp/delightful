//
//  AppDelegate.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBoxNavigationControllerDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign, getter = isDemoMode) BOOL demoMode;

@property (nonatomic, strong) PhotoBoxNavigationControllerDelegate *navigationDelegate;

/**
 *  Call this method to show the Update Info if needed.
 *
 *  @return YES if the update info screen is shown. NO otherwise.
 */
- (BOOL)showUpdateInfoViewIfNeeded;

@end
