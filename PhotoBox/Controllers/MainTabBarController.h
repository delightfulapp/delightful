//
//  MainTabBarController.h
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewControllerTransitionToSizeDelegate <NSObject>

- (void)dlf_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end

@interface MainTabBarController : UITabBarController

@end
