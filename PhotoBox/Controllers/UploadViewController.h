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

@interface UploadViewController : UIViewController

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *uploads;

- (void)startUpload;

@end
