//
//  PhotosInAlbumDataSource.h
//  Delightful
//
//  Created by  on 10/22/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "GroupedPhotosDataSource.h"

@interface PhotosSubsetDataSource : YapDataSource <PhotosDataSourceViewMappingDelegate>

- (void)setFilterBlock:(BOOL (^)(NSString *, NSString *, id))filterBlock name:(NSString *)filterName;

@end
