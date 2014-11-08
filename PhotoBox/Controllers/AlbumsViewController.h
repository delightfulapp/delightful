//
//  AlbumsViewController.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosCollectionWithSearchViewController.h"

@protocol AlbumsViewControllerScrollDelegate <NSObject>

@optional
- (void)didScroll:(UIScrollView *)scrollView;

@end

@interface AlbumsViewController : PhotosCollectionWithSearchViewController

@property (nonatomic, weak) id<AlbumsViewControllerScrollDelegate>scrollDelegate;

@property (nonatomic, assign) CGFloat headerViewHeight;

@end
