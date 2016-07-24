//
//  GroupedPhotosDataSource.h
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "YapDataSource.h"

@class DLFYapDatabaseViewAndMapping;

typedef NS_ENUM(NSInteger, PhotosSortKey) {
    PhotosSortKeyDateUploaded,
    PhotosSortKeyDateTaken
};

extern NSString *const dateUploadedLastViewName;
extern NSString *const dateTakenLastViewName;
extern NSString *const dateUploadedFirstViewName;
extern NSString *const dateTakenFirstViewName;

@protocol PhotosDataSourceViewMappingDelegate <NSObject>

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending;

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending completion:(void(^)())completion;

- (DLFYapDatabaseViewAndMapping *)selectedFlattenedViewMapping;

@end

@interface GroupedPhotosDataSource : YapDataSource <PhotosDataSourceViewMappingDelegate>

@end
