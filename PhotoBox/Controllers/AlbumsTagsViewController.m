//
//  AlbumsTagsViewController.m
//  Delightful
//
//  Created by Nico Prananta on 11/23/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumsTagsViewController.h"

#import "DelightfulTabBar.h"

#import <UIView+AutoLayout.h>

#import "UIViewController+DelightfulViewControllers.h"

@interface AlbumsTagsViewController ()

@property (nonatomic, weak) DelightfulTabBar *customTabBar;

@end

@implementation AlbumsTagsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.customTabBar setHidden:NO];
    [self.tabBar setHidden:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DelightfulTabBar *)customTabBar {
    if (!_customTabBar) {
        DelightfulTabBar *tabBar = [[DelightfulTabBar alloc] init];
        [self.view addSubview:tabBar];
        [tabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [tabBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
        [tabBar autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
        [tabBar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view withOffset:([[self class] leftViewControllerVisibleWidth] - CGRectGetWidth(self.view.frame))];
        [tabBar autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.tabBar];
        _customTabBar = tabBar;
    }
    return _customTabBar;
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:viewControllers.count];
    for (UIViewController *viewController in viewControllers) {
        [buttons addObject:viewController.tabBarItem];
    }
    
    [self.customTabBar setItems:buttons];
    
    [self setSelectedIndex:0];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    
    [self.customTabBar setSelectedItem:((UIViewController *)self.viewControllers[selectedIndex]).tabBarItem];
}

@end
