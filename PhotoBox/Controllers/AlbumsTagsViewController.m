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

#import "AlbumsViewController.h"

@interface AlbumsTagsViewController ()

@property (nonatomic, weak) DelightfulTabBar *customTabBar;

@property (nonatomic, assign) BOOL hasLayoutSubviews;

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
    
    [self.customTabBar addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedItem)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
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
        [tabBar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
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

// Workaround for iOS UITabBarController layout issue.
// In iOS7, the tab bar overlaps with the view to be displayed.
// The height of the view to be displayed with a UITabBarController needs
// to be shrinked by the height of the tab bar.
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.hasLayoutSubviews) {
        self.hasLayoutSubviews = YES;
        static int barHeight = 0;
        if (barHeight == 0) {
            barHeight = CGRectGetHeight(self.tabBar.frame);
        }
        UIView* CV = (UIView*)self.view.subviews.firstObject;
        CV.autoresizesSubviews = YES;
        UIView* GCV = (UIView*) CV.subviews.firstObject;
        UIView* GGCV = (UIView*) GCV.subviews.firstObject;
        CGRect frame = CV.frame;
        frame.size.height = self.view.frame.size.height - barHeight;
        CV.frame = frame;
        GCV.frame = frame;
        GGCV.frame = frame;
    }
    
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // this is seriously weird, the selected and the shown view controller is reversed!
    NSInteger index = abs(1-self.selectedIndex);
    AlbumsViewController *shownVC = (AlbumsViewController *)[self.viewControllers objectAtIndex:index];
    [shownVC scrollViewDidScroll:shownVC.collectionView];
}

@end
