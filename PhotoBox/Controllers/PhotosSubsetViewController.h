//
//  PhotosSubsetViewController.h
//  Delightful
//
//  Created by  on 10/22/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosViewController.h"

@class PhotosCollection;

@interface PhotosSubsetViewController : PhotosViewController

@property (nonatomic, copy) NSString *filterName;

@property (nonatomic, copy) NSString *objectKey;

@property (nonatomic, strong) PhotosCollection *item;

@end
