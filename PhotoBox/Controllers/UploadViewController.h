//
//  UploadViewController.h
//  Delightful
//
//  Created by Nico Prananta on 6/21/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UPLOAD_ITEM_WIDTH 53

#define UPLOAD_BAR_HEIGHT 22

@class Album;

@interface UploadViewController : UIViewController

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *uploads;

@property (nonatomic, strong) NSString *tags;

@property (nonatomic, strong) Album *album;

@property (nonatomic, assign) BOOL privatePhotos;

- (void)startUpload;

@end
