//
//  AlbumsDataSource.m
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "AlbumsDataSource.h"
#import "DLFYapDatabaseViewAndMapping.h"
#import "DLFDatabaseManager.h"
#import "Album.h"
#import "SortTableViewController.h"
#import "SortingConstants.h"

NSString *albumsUpdatedLastViewName = @"updated-last-albums";
NSString *albumsUpdatedFirstViewName = @"updated-first-albums";
NSString *albumsAlphabeticalAscendingViewName = @"alphabetical-asc-albums";
NSString *albumsAlphabeticalDescendingViewName = @"alphabetical-desc-albums";

@interface AlbumsDataSource ()

@end

@implementation AlbumsDataSource

- (void)setupMapping {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.updatedLastAlbumsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsUpdatedLastViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateLastPhotoAdded)) sortKeyAsc:NO];
        self.updatedFirstAlbumsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsUpdatedFirstViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateLastPhotoAdded)) sortKeyAsc:YES];
        self.alphabetAscAlbumsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsAlphabeticalAscendingViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(name)) sortKeyAsc:YES];
        self.alphabetDescAlbumsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsAlphabeticalDescendingViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(name)) sortKeyAsc:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDefaultMapping];
        });
    });
}

- (void)setDefaultMapping {
    NSString *sort = dateLastPhotoAddedDescSortKey;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:DLF_LAST_SELECTED_ALBUMS_SORT]) {
        sort = [[NSUserDefaults standardUserDefaults] objectForKey:DLF_LAST_SELECTED_ALBUMS_SORT];
    }
    AlbumsSortKey selectedSortKey;
    NSArray *sortArray = [sort componentsSeparatedByString:@","];
    if ([[sortArray objectAtIndex:0] isEqualToString:NSStringFromSelector(@selector(dateLastPhotoAdded))]) {
        selectedSortKey = AlbumsSortKeyDateLastUpdated;
    } else {
        selectedSortKey = AlbumsSortKeyName;
    }
    BOOL ascending = YES;
    if ([[[sortArray objectAtIndex:1] lowercaseString] isEqualToString:@"desc"]) {
        ascending = NO;
    }
    
    [self sortBy:selectedSortKey ascending:ascending];
}

- (void)sortBy:(AlbumsSortKey)sortBy ascending:(BOOL)ascending {
    if (sortBy == AlbumsSortKeyName) {
        [self setSelectedViewMapping:(ascending)?self.alphabetAscAlbumsViewMapping:self.alphabetDescAlbumsViewMapping];
    } else if (sortBy == AlbumsSortKeyDateLastUpdated) {
        [self setSelectedViewMapping:(ascending)?self.updatedFirstAlbumsViewMapping:self.updatedLastAlbumsViewMapping];
    }
}

- (searchFilterBlock)searchFilterBlock {
    return ^BOOL(NSString *collection, NSString *key, Album *object, NSString *searchText) {
        return ([object.name rangeOfString:searchText options:NSCaseInsensitiveSearch range:NSMakeRange(0, (searchText.length==1)?1:object.name.length)].location==NSNotFound)?NO:YES;
    };
}

@end
