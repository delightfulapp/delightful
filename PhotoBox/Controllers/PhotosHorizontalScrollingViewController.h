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
- (void)photosHorizontalWillClose;

@end

@interface PhotosHorizontalScrollingViewController : PhotoBoxViewController <CustomAnimationTransitionFromViewControllerDelegate>

@property (nonatomic, strong) Photo *firstShownPhoto;
@property (nonatomic, assign) NSInteger firstShownPhotoIndex;
@property (nonatomic, weak) id<PhotosHorizontalScrollingViewControllerDelegate>delegate;

@end
