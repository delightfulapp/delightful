//
//  PhotoTagsCollectionViewController.h
//  Delightful
//
//  Created by  on 12/17/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoTagsCollectionViewController;
@class DLFAsset;

@protocol PhotoTagsCollectionViewControllerDelegate <NSObject>

@optional
- (void)photoTagsViewController:(PhotoTagsCollectionViewController *)controller didChangeSmartTagsForAsset:(DLFAsset *)asset;

@end

@interface PhotoTagsCollectionViewController : UICollectionViewController

@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, assign) id<PhotoTagsCollectionViewControllerDelegate>delegate;

@end
