//
//  PhotosSubsetViewController.h
//  Delightful
//
//  Created by  on 10/22/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "YapBackedPhotosViewController.h"

@interface PhotosSubsetViewController : YapBackedPhotosViewController

@property (nonatomic, copy) NSString *filterName;

@property (nonatomic, copy) NSString *objectKey;

@end
