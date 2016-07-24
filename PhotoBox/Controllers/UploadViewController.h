//
//  UploadViewController.h
//  Delightful
//
//  Created by Nico Prananta on 6/21/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UPLOAD_ITEM_WIDTH 53

#define UPLOAD_BAR_HEIGHT 22

@class UploadViewController;

@protocol UploadViewControllerDelegate <NSObject>

@optional
- (void)uploadViewControllerDidFinishUploading:(UploadViewController *)uploadViewController;
- (void)uploadViewControllerDidClose:(UploadViewController *)uploadViewController;

@end

@class Album;

@interface UploadViewController : UIViewController

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *uploads;

@property (nonatomic, strong) NSString *tags;

@property (nonatomic, strong) Album *album;

@property (nonatomic, assign) BOOL privatePhotos;

@property (nonatomic, weak, readonly) UIButton *reloadButton;

@property (nonatomic, weak, readonly) UIButton *cancelButton;

@property (nonatomic, weak) id<UploadViewControllerDelegate>delegate;

- (void)reloadUpload;

- (void)showReloadButtons:(BOOL)show;

@end
