//
//  PhotosInAlbumDataSource.h
//  Delightful
//
//  Created by  on 10/22/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "GroupedPhotosDataSource.h"

@interface PhotosSubsetDataSource : YapDataSource <PhotosDataSourceViewMappingDelegate>

- (void)setFilterName:(NSString *)filterName objectKey:(NSString *)objectKey filterKey:(NSString *)filterKey;

@end
