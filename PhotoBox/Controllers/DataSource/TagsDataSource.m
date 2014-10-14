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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        self.alphabeticalFirstTagsViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:tagsAlphabeticalFirstViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(tagId)) sortKeyAsc:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setSelectedViewMapping:self.alphabeticalFirstTagsViewMapping];
        });
    });
    
}

@end
