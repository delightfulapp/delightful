//
//  AlbumsDataSource.m
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "AlbumsDataSource.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import "DLFDatabaseManager.h"

#import "Album.h"

NSString *albumsUpdatedLastViewName = @"updated-last-albums";
NSString *albumsUpdatedFirstViewName = @"updated-first-albums";
NSString *albumsAlphabeticalAscendingViewName = @"alphabetical-asc-albums";
NSString *albumsAlphabeticalDescendingViewName = @"alphabetical-desc-albums";

@implementation AlbumsDataSource

- (void)setupDatabase {
    [super setupDatabase];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.updatedLastAlbumsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsUpdatedLastViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateLastPhotoAdded)) sortKeyAsc:NO];
        self.updatedFirstAlbumsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsUpdatedFirstViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateLastPhotoAdded)) sortKeyAsc:YES];
        self.alphabetAscAlbumsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsAlphabeticalAscendingViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(name)) sortKeyAsc:YES];
        self.alphabetDescAlbumsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsAlphabeticalDescendingViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(name)) sortKeyAsc:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setSelectedViewMapping:self.updatedLastAlbumsViewMapping];
        });
    });
}

- (void)sortBy:(AlbumsSortKey)sortBy ascending:(BOOL)ascending {
    if (sortBy == AlbumsSortKeyName) {
        [self setSelectedViewMapping:(ascending)?self.alphabetAscAlbumsViewMapping:self.alphabetDescAlbumsViewMapping];
    } else if (sortBy == AlbumsSortKeyDateLastUpdated) {
        [self setSelectedViewMapping:(ascending)?self.updatedFirstAlbumsViewMapping:self.updatedLastAlbumsViewMapping];
    }
}

@end
