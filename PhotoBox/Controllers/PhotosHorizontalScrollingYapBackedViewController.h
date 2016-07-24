//
//  PhotosHorizontalScrollingYapBackedViewController.h
//  Delightful
//
//  Created by  on 10/2/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "PhotosHorizontalScrollingViewController.h"

@class DLFYapDatabaseViewAndMapping;

@interface PhotosHorizontalScrollingYapBackedViewController : PhotosHorizontalScrollingViewController

+ (PhotosHorizontalScrollingYapBackedViewController *)defaultControllerWithGroupedViewMapping:(DLFYapDatabaseViewAndMapping *)groupedViewMapping;

+ (PhotosHorizontalScrollingYapBackedViewController *)defaultControllerWithViewMapping:(DLFYapDatabaseViewAndMapping *)viewMapping;

@end
