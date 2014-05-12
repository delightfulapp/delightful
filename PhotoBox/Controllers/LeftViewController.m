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

#import "AlbumsViewController.h"

#import "TagsViewController.h"

#import "AlbumsTagsViewController.h"

@interface LeftViewController () <AlbumsViewControllerScrollDelegate>

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
        [view autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
        [view autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
        [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
        [view autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
        [viewController didMoveToParentViewController:self];
        _rootViewController = viewController;
        
        AlbumsTagsViewController *albumsTags = (AlbumsTagsViewController *)viewController;
        for (AlbumsViewController *vc in albumsTags.viewControllers) {
            [vc setScrollDelegate:self];
            [vc setHeaderViewHeight:self.headerView.intrinsicContentSize.height];
            [vc restoreContentInset];
        }
        
        [self.view bringSubviewToFront:self.headerView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor albumsBackgroundColor]];
    
    [self.headerView.galleryButton addTarget:self action:@selector(didTapGallery:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView.downloadedButton addTarget:self action:@selector(didTapDownloadHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView.favoriteButton addTarget:self action:@selector(didTapFavorites:) forControlEvents:UIControlEventTouchUpInside];
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
    [self loadPhotosInAlbum:[Album favoritesAlbum]];
}

- (void)didTapDownloadHistory:(id)sender {
    [self loadPhotosInAlbum:[Album downloadHistoryAlbum]];
}

#pragma mark - AlbumsViewControllerScrollDelegate

- (void)didScroll:(UIScrollView *)scrollView {
    CGFloat minYToMoveDownloaded = CGRectGetHeight(self.headerView.frame) - CGRectGetHeight(self.headerView.downloadedButton.frame);
    CGFloat minFavoritesToDownloadSpace = -CGRectGetHeight(self.headerView.favoriteButton.frame)-20;
    CGFloat minDownloadedToGallerySpace = -CGRectGetHeight(self.headerView.downloadedButton.frame);
    
    CGFloat downloadedConstant = MAX(MIN(10, 10-(scrollView.contentOffset.y-minYToMoveDownloaded)), minDownloadedToGallerySpace);
    CGFloat favoritedConstant = MAX(MIN(10, 10-scrollView.contentOffset.y), minFavoritesToDownloadSpace);

    [self.headerView.downloadedToGalleryConstraint setConstant:downloadedConstant];
    [self.headerView.favoriteToDownloadedSpaceConstraint setConstant:favoritedConstant];
}


@end
