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

#import "NPRImageDownloader.h"

static void * imageDownloadContext = &imageDownloadContext;

@interface MainTabBarController ()

@property (nonatomic, assign) int numberOfDownloads;

@property (nonatomic, assign) int numberOfUploads;

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NPRImageDownloader sharedDownloader] addObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfDownloads)) options:0 context:imageDownloadContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showBadgeOnMoreBarItem {
    UIViewController *moreVC = [self.viewControllers lastObject];
    int totalOperation = self.numberOfDownloads + self.numberOfUploads;
    if (totalOperation > 0) {
        [moreVC.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d", totalOperation]];
    } else {
        [moreVC.tabBarItem setBadgeValue:nil];
        
        [[NPRNotificationManager sharedManager] postNotificationWithImage:nil position:NPRNotificationPositionBottom type:NPRNotificationTypeSuccess string:NSLocalizedString(@"Image(s) are saved to Photo gallery", nil) accessoryType:NPRNotificationAccessoryTypeNone accessoryView:nil duration:1 onTap:nil];
    }
    
}

#pragma mark - Orientation

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

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(numberOfDownloads))] && context == imageDownloadContext) {
        self.numberOfDownloads = (int)[[NPRImageDownloader sharedDownloader] numberOfDownloads];
        [self showBadgeOnMoreBarItem];
    }
}

@end
