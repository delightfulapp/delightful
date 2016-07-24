//
//  PhotosCollectionWithSearchViewController.h
//  Delightful
//
//  Created by  on 11/8/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "PhotoBoxViewController.h"

@interface PhotosCollectionWithSearchViewController : PhotoBoxViewController

@property (nonatomic, strong, readonly) UISearchBar *searchBar;

- (void)showSearchBar:(BOOL)show;

@end
