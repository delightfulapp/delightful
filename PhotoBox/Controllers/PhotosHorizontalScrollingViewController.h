//
//  PhotosHorizontalScrollingViewController.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosViewController.h"
#import "ShowFullScreenPhotosAnimatedTransitioning.h"

@class Photo;
@class PhotosHorizontalScrollingViewController;

@protocol PhotosHorizontalScrollingViewControllerDelegate <NSObject>

- (void)photosHorizontalScrollingViewController:(PhotosHorizontalScrollingViewController *)viewController didChangePage:(NSInteger)page item:(NSManagedObject *)item;
- (UIView *)snapshotView;
- (CGRect)selectedItemRectInSnapshot;
- (void)shouldClosePhotosHorizontalViewController:(PhotosHorizontalScrollingViewController *)controller;
- (void)willDismissViewController:(PhotosHorizontalScrollingViewController *)controller;
- (void)cancelDismissViewController:(PhotosHorizontalScrollingViewController *)controller;

@end

@interface PhotosHorizontalScrollingViewController : UICollectionViewController <CustomAnimationTransitionFromViewControllerDelegate>

@property (nonatomic, strong) Photo *firstShownPhoto;
@property (nonatomic, weak) id<PhotosHorizontalScrollingViewControllerDelegate>delegate;
@property (nonatomic, assign) BOOL hideDownloadButton;
@property (nonatomic, strong) CollectionViewDataSource *dataSource;

- (void)setupDataSource;
- (NSString *)cellIdentifier;

@end
