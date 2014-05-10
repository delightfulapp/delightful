//
//  PanelsContainerViewController.m
//  Delightful
//
//  Created by Nico Prananta on 11/24/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PanelsContainerViewController.h"

#import "PhotoBoxViewController.h"

@interface PanelsContainerViewController ()

@end

@implementation PanelsContainerViewController

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
    
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:0 context:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleLeftPanel:(id)sender {
    [super toggleLeftPanel:sender];
    
    [self toggleDataSourcePaused];
}

- (void)toggleDataSourcePaused {
    PhotoBoxViewController *visibleController, *hiddenController;
    
    PhotoBoxViewController *centerPanel = (PhotoBoxViewController *)((UINavigationController *)self.centerPanel).viewControllers[0];
    PhotoBoxViewController *leftPanel = (PhotoBoxViewController *)((UITabBarController *)self.leftPanel).selectedViewController;
    
    if (self.state == JASidePanelCenterVisible) {
        visibleController = centerPanel;
        hiddenController = leftPanel;
    } else if (self.state == JASidePanelLeftVisible) {
        visibleController = leftPanel;
        hiddenController = centerPanel;
    }
}

- (void)toggleStatusBarHidden {
    if (self.state == JASidePanelCenterVisible) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    } else if (self.state == JASidePanelLeftVisible) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
        [self toggleDataSourcePaused];
        [self toggleStatusBarHidden];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
