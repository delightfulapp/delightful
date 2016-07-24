//
//  TagsDataSource.m
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "TagsDataSource.h"
#import "DLFYapDatabaseViewAndMapping.h"
#import "DLFDatabaseManager.h"
#import "Tag.h"
#import "SortingConstants.h"
#import "SortTableViewController.h"

NSString *tagsAlphabeticalFirstViewName = @"alphabetical-first-tags";
NSString *tagsAlphabeticalLastViewName = @"alphabetical-last-tags";
NSString *numbersFirstViewName = @"numbers-first-tags";
NSString *numbersLastViewName = @"numbers-last-tags";

@interface TagsDataSource ()

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *alphabeticalFirstTagsViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *alphabeticalLastTagsViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *numberFirstTagsViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *numbersLastTagsViewMapping;

@end

@implementation TagsDataSource

- (void)setupDatabase {
    [super setupDatabase];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        self.alphabeticalFirstTagsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:tagsAlphabeticalFirstViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(tagId)) sortKeyAsc:YES];
        self.alphabeticalLastTagsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:tagsAlphabeticalLastViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(tagId)) sortKeyAsc:NO];
        self.numberFirstTagsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:numbersFirstViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(count)) sortKeyAsc:YES];
        self.numbersLastTagsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:numbersLastViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(count)) sortKeyAsc:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDefaultMapping];
        });
    });
}

- (void)setDefaultMapping {
    NSString *sort = nameAscSortKey;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:DLF_LAST_SELECTED_TAGS_SORT]) {
        sort = [[NSUserDefaults standardUserDefaults] objectForKey:DLF_LAST_SELECTED_TAGS_SORT];
    }
    TagsSortKey selectedSortKey;
    NSArray *sortArray = [sort componentsSeparatedByString:@","];
    BOOL ascending = YES;
    if ([[sortArray objectAtIndex:0] isEqualToString:NSStringFromSelector(@selector(name))]) {
        selectedSortKey = TagsSortKeyName;
    } else {
        selectedSortKey = TagsSortKeyNumberOfPhotos;
    }
    if ([[[sortArray objectAtIndex:1] lowercaseString] isEqualToString:@"desc"]) {
        ascending = NO;
    }
    
    [self sortBy:selectedSortKey ascending:ascending];
}

- (void)sortBy:(TagsSortKey)sortBy ascending:(BOOL)ascending {
    if (sortBy == TagsSortKeyName) {
        if (ascending) {
            [self setSelectedViewMapping:self.alphabeticalFirstTagsViewMapping];
        } else {
            [self setSelectedViewMapping:self.alphabeticalLastTagsViewMapping];
        }
    } else if (sortBy == TagsSortKeyNumberOfPhotos) {
        if (ascending) {
            [self setSelectedViewMapping:self.numberFirstTagsViewMapping];
        } else {
            [self setSelectedViewMapping:self.numbersLastTagsViewMapping];
        }
    }
}

- (searchFilterBlock)searchFilterBlock {
    return ^BOOL(NSString *collection, NSString *key, Tag *object, NSString *searchText) {
        return ([object.tagId rangeOfString:searchText options:NSCaseInsensitiveSearch range:NSMakeRange(0, (searchText.length==1)?1:object.tagId.length)].location==NSNotFound)?NO:YES;
    };
}

@end
