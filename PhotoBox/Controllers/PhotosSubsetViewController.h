//
//  PhotosSubsetViewController.h
//  Delightful
//
//  Created by  on 10/22/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosViewController.h"

@interface PhotosSubsetViewController : PhotosViewController

- (id)initWithFilterBlock:(BOOL(^)(NSString *collection, NSString *key, id object))filterBlock name:(NSString *)filterName;

@property (nonatomic, copy) BOOL (^filterBlock)(NSString *collection, NSString *key, id object);

@property (nonatomic, copy) NSString *filterName;

@end
