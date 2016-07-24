//
//  LocalViewController.m
//  Delightful
//
//  Created by  on 11/16/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "LocalViewController.h"

#import "MainTabBarController.h"

@interface LocalViewController () <ViewControllerTransitionToSizeDelegate>

@end

@implementation LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectedSegmentDidChange:(UISegmentedControl *)sender {
    [self setSelectedIndex:sender.selectedSegmentIndex];
}

#pragma mark - <ViewControllerTransitionToSizeDelegate>

- (void)dlf_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    for (UIViewController *controller in self.viewControllers) {
        if ([controller respondsToSelector:@selector(dlf_viewWillTransitionToSize:withTransitionCoordinator:)]) {
            [((id)controller) dlf_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
        }
    }
}

@end
