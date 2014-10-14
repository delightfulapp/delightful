//
//  MainTabBarController.m
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "MainTabBarController.h"

#import "SyncEngine.h"

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

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    
    NSLog(@"Change index");
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    [[SyncEngine sharedEngine] setPauseSync:YES];
    [super setSelectedViewController:selectedViewController];
    [[SyncEngine sharedEngine] setPauseSync:NO];
}

@end
