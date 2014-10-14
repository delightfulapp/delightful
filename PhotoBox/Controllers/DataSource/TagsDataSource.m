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

@implementation TagsDataSource

- (void)setupDatabase {
    [super setupDatabase];
    
    self.alphabeticalFirstTagsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:tagsAlphabeticalFirstViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(tagId)) sortKeyAsc:YES];
    
    
    [self setSelectedViewMapping:self.alphabeticalFirstTagsViewMapping];
}

@end
