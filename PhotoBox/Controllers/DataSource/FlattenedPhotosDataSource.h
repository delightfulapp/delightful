//
//  FlattenedPhotosDataSource.h
//  Delightful
//
//  Created by  on 9/29/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "YapDataSource.h"

@class DLFYapDatabaseViewAndMapping;

@interface FlattenedPhotosDataSource : YapDataSource

- (id)initWithCollectionView:(id)collectionView groupedViewMapping:(DLFYapDatabaseViewAndMapping *)groupedViewMapping;

- (id)initWithCollectionView:(id)collectionView viewMapping:(DLFYapDatabaseViewAndMapping *)viewMapping;

@end
