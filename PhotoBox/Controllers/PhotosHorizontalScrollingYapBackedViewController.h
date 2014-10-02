//
//  PhotosHorizontalScrollingYapBackedViewController.h
//  Delightful
//
//  Created by  on 10/2/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosHorizontalScrollingViewController.h"

@class DLFYapDatabaseViewAndMapping;

@interface PhotosHorizontalScrollingYapBackedViewController : PhotosHorizontalScrollingViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout groupedViewMapping:(DLFYapDatabaseViewAndMapping *)groupedViewMapping;

@end
