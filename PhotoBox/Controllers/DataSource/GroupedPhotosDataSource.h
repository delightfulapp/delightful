//
//  GroupedPhotosDataSource.h
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "YapDataSource.h"

@class DLFYapDatabaseViewAndMapping;

typedef NS_ENUM(NSInteger, PhotosSortKey) {
    PhotosSortKeyDateUploaded,
    PhotosSortKeyDateTaken
};

@interface GroupedPhotosDataSource : YapDataSource

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending;

- (DLFYapDatabaseViewAndMapping *)selectedFlattenedViewMapping;

@end
