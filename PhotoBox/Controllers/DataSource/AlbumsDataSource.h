//
//  AlbumsDataSource.h
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "YapDatasourceWithSearching.h"

@class DLFYapDatabaseViewAndMapping;

typedef NS_ENUM(NSInteger, AlbumsSortKey) {
    AlbumsSortKeyName,
    AlbumsSortKeyDateLastUpdated
};

extern NSString *albumsUpdatedLastViewName;
extern NSString *albumsUpdatedFirstViewName;
extern NSString *albumsAlphabeticalAscendingViewName;
extern NSString *albumsAlphabeticalDescendingViewName;

@interface AlbumsDataSource : YapDatasourceWithSearching

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *updatedLastAlbumsViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *updatedFirstAlbumsViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *alphabetAscAlbumsViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *alphabetDescAlbumsViewMapping;

- (void)sortBy:(AlbumsSortKey)sortBy ascending:(BOOL)ascending;

@end
