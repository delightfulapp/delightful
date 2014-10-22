//
//  TagsDataSource.m
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "TagsDataSource.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import "DLFDatabaseManager.h"

#import "Tag.h"

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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setSelectedViewMapping:self.alphabeticalFirstTagsViewMapping];
        });
        self.numberFirstTagsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:numbersFirstViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(count)) sortKeyAsc:YES];
        self.numbersLastTagsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:numbersLastViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(count)) sortKeyAsc:NO];
    });
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

@end
