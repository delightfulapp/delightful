//
//  MainTabBarController.h
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewControllerTransitionToSizeDelegate <NSObject>

- (void)dlf_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end

@interface MainTabBarController : UITabBarController

@end
