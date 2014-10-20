//
//  GroupedPhotosDataSource.m
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "GroupedPhotosDataSource.h"

#import "Photo.h"

#import "DLFDatabaseManager.h"

#import "DLFYapDatabaseViewAndMapping.h"

NSString *dateUploadedLastViewName = @"date-uploaded-last-photos";
NSString *dateTakenLastViewName = @"date-taken-last-photos";
NSString *dateUploadedFirstViewName = @"date-uploaded-first-photos";
NSString *dateTakenFirstViewName = @"date-taken-first-photos";

@implementation GroupedPhotosDataSource

- (void)setupDatabase {
    [super setupDatabase];
    
    // last uploaded -> first uploaded view and mappings grouped
    self.dateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateUploadedLastViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateUploaded)) sortKeyAsc:NO groupKey:NSStringFromSelector(@selector(dateUploadedString)) groupSortAsc:NO];
    
    // first uploaded -> last uploaded view and mappings grouped
    self.dateUploadedFirstViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateUploadedFirstViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateUploaded)) sortKeyAsc:YES groupKey:NSStringFromSelector(@selector(dateUploadedString)) groupSortAsc:YES];
    
    // first taken -> last taken view and mappings grouped
    self.dateTakenFirstViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateTakenFirstViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateTaken)) sortKeyAsc:YES groupKey:NSStringFromSelector(@selector(dateTakenString)) groupSortAsc:YES];
    
    // last taken -> first taken view and mappings grouped
    self.dateTakenLastViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateTakenLastViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateTaken)) sortKeyAsc:NO groupKey:NSStringFromSelector(@selector(dateTakenString)) groupSortAsc:NO];

    [self setSelectedViewMapping:self.dateUploadedLastViewMapping];
}

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending {
    if (sortBy == PhotosSortKeyDateUploaded) {
        [self setSelectedViewMapping:(ascending)?self.dateUploadedFirstViewMapping:self.dateUploadedLastViewMapping];
    } else if (sortBy == PhotosSortKeyDateTaken) {
        [self setSelectedViewMapping:(ascending)?self.dateTakenFirstViewMapping:self.dateTakenLastViewMapping];
    }
}

@end
