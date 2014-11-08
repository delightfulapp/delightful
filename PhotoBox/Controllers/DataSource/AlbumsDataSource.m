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

@interface AlbumsDataSource ()

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *unfilteredSelectedViewMapping;

@end

@implementation AlbumsDataSource

- (void)setupMapping {
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

- (void)setDefaultMapping {}

- (void)sortBy:(AlbumsSortKey)sortBy ascending:(BOOL)ascending {
    if (sortBy == AlbumsSortKeyName) {
        [self setSelectedViewMapping:(ascending)?self.alphabetAscAlbumsViewMapping:self.alphabetDescAlbumsViewMapping];
    } else if (sortBy == AlbumsSortKeyDateLastUpdated) {
        [self setSelectedViewMapping:(ascending)?self.updatedFirstAlbumsViewMapping:self.updatedLastAlbumsViewMapping];
    }
}

- (void)filterWithSearchText:(NSString *)searchText {
    if (searchText && searchText.length > 0) {
        if (!self.unfilteredSelectedViewMapping) self.unfilteredSelectedViewMapping = self.selectedViewMapping;
        DLFYapDatabaseViewAndMapping *filteredMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:self.unfilteredSelectedViewMapping.viewName database:self.database collection:self.unfilteredSelectedViewMapping.collection isPersistent:NO skipInitialViewPopulation:NO filterName:[NSString stringWithFormat:@"%@-%@", self.unfilteredSelectedViewMapping.viewName, searchText] groupSortAsc:self.unfilteredSelectedViewMapping.groupSortAscending filterBlock:^BOOL(NSString *collection, NSString *key, Album *object) {
            return ([object.name rangeOfString:searchText options:NSCaseInsensitiveSearch range:NSMakeRange(0, (searchText.length==1)?1:object.name.length)].location==NSNotFound)?NO:YES;
        }];
        [self setSelectedViewMapping:filteredMapping];
    } else {
        if (self.unfilteredSelectedViewMapping) {
            [self setSelectedViewMapping:self.unfilteredSelectedViewMapping];
            self.unfilteredSelectedViewMapping = nil;
        }
    }
}

@end
