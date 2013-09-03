//
//  PhotosViewControllerDataSource.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CollectionViewDataSource.h"


@interface PhotosViewControllerDataSource : CollectionViewDataSource

@property (nonatomic, strong) NSString *groupKey;

@end
