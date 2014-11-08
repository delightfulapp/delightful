//
//  PhotosCollectionWithSearchViewController.m
//  Delightful
//
//  Created by  on 11/8/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosCollectionWithSearchViewController.h"

@interface PhotosCollectionWithSearchViewController ()

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation PhotosCollectionWithSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), 0)];
    [self.searchBar setSearchBarStyle:UISearchBarStyleProminent];
    [self.view addSubview:self.searchBar];
    [self.searchBar sizeToFit];
    
    [self restoreContentInset];
}

- (void)restoreContentInset {
    [self.collectionView setContentInset:UIEdgeInsetsMake(self.searchBar.isHidden?CGRectGetMaxY(self.navigationController.navigationBar.frame):CGRectGetMaxY(self.searchBar.frame), 0, 0, 0)];
    [self.collectionView setScrollIndicatorInsets:self.collectionView.contentInset];
}

- (void)showSearchBar:(BOOL)show {
    if (self.searchBar.isHidden == show) {
        [self.searchBar setHidden:!show];
        [self restoreContentInset];
        [self.collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top)];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        [self showSearchBar:([self.dataSource numberOfItems] > 0)?YES:NO];
    }
}

@end
