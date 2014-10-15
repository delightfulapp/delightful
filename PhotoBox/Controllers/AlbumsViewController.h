//
//  AlbumsViewController.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxViewController.h"

@protocol AlbumsViewControllerScrollDelegate <NSObject>

@optional
- (void)didScroll:(UIScrollView *)scrollView;

@end

@interface AlbumsViewController : PhotoBoxViewController

- (void)tapOnAllAlbum:(UITapGestureRecognizer *)gesture;

- (void)restoreContentInset;

@property (nonatomic, weak) id<AlbumsViewControllerScrollDelegate>scrollDelegate;

@property (nonatomic, assign) CGFloat headerViewHeight;

@end
