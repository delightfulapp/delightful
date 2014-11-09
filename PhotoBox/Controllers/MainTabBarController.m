//
//  MainTabBarController.m
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "MainTabBarController.h"

#import "SyncEngine.h"

#import "PhotoBoxViewController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Tabbar view will transition to size %@", NSStringFromCGSize(size));
    
    for (UINavigationController *navCon in self.viewControllers) {
        for (UIViewController *controller in navCon.viewControllers) {
            if ([controller respondsToSelector:@selector(dlf_viewWillTransitionToSize:withTransitionCoordinator:)]) {
                [((id)controller) dlf_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
            }
        }
    }
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

@end
