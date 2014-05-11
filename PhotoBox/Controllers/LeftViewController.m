//
//  LeftViewController.m
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "LeftViewController.h"

#import <UIView+Autolayout.h>

#import "LeftPanelHeaderView.h"

#import "UIViewController+Additionals.h"

#import "Album.h"

@interface LeftViewController ()

@property (nonatomic, strong) id rootViewController;

@property (nonatomic, strong) LeftPanelHeaderView *headerView;

@end

@implementation LeftViewController

- (id)initWithRootViewController:(id)viewController {
    self = [super init];
    if (self) {
        [self.view addSubview:self.headerView];
        [self.headerView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
        [self.headerView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
        [self.headerView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
        
        [self addChildViewController:viewController];
        [viewController willMoveToParentViewController:self];
        UIView *view = ((UIViewController *)viewController).view;
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:view];
        [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.headerView];
        [view autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
        [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
        [view autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
        [viewController didMoveToParentViewController:self];
        _rootViewController = viewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.headerView.galleryButton addTarget:self action:@selector(didTapGallery:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView.favoritesButton addTarget:self action:@selector(didTapFavorites:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView.downloadedButton addTarget:self action:@selector(didTapDownloadHistory:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (LeftPanelHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LeftPanelHeaderView class]) owner:self options:nil] firstObject];
        [_headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _headerView;
}

#pragma mark - Buttons

- (void)didTapGallery:(id)sender {
    [self loadPhotosInAlbum:[Album allPhotosAlbum]];
}

- (void)didTapFavorites:(id)sender {
    
}

- (void)didTapDownloadHistory:(id)sender {
    
}


@end
