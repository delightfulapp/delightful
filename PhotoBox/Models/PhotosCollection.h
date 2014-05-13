//
//  PhotosCollection.h
//  Delightful
//
//  Created by Nico Prananta on 5/13/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotoBoxModel.h"

@interface PhotosCollection : PhotoBoxModel

@property (nonatomic, copy, readonly) NSArray *photos;

@property (nonatomic, assign) NSInteger totalPhotos;

+ (void)setModelsCollection:(NSArray *)albums;

+ (NSArray *)modelsCollection;

+ (void)setModelsCollectionLastRefresh:(NSDate *)date;

+ (BOOL)needRefreshModelsCollection;

+ (void)setTotalCountCollection:(NSInteger)totalCount;

+ (NSInteger)totalCountCollection;

@end
