//
//  AppDelegate.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign, getter = isDemoMode) BOOL demoMode;

@end
