//
//  GroupedPhotosDataSource.m
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "GroupedPhotosDataSource.h"

#import "Photo.h"

#import "DLFYapDatabaseViewAndMapping.h"

NSString *dateUploadedLastViewName = @"date-uploaded-last-photos";
NSString *dateTakenLastViewName = @"date-taken-last-photos";
NSString *dateUploadedFirstViewName = @"date-uploaded-first-photos";
NSString *dateTakenFirstViewName = @"date-taken-first-photos";

@implementation GroupedPhotosDataSource

- (void)setupDatabase {
    [super setupDatabase];
    
    // last uploaded -> first uploaded view and mappings grouped
    self.dateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateUploadedLastViewName database:self.database sortKey:NSStringFromSelector(@selector(dateUploadedString)) sortKeyAsc:NO groupKey:NSStringFromSelector(@selector(dateUploadedString)) groupSortAsc:NO];
    
    // first uploaded -> last uploaded view and mappings grouped
    self.dateUploadedFirstViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateUploadedFirstViewName database:self.database sortKey:NSStringFromSelector(@selector(dateUploadedString)) sortKeyAsc:YES groupKey:NSStringFromSelector(@selector(dateUploadedString)) groupSortAsc:YES];
    
    // first taken -> last taken view and mappings grouped
    self.dateTakenFirstViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateTakenFirstViewName database:self.database sortKey:NSStringFromSelector(@selector(dateTakenString)) sortKeyAsc:YES groupKey:NSStringFromSelector(@selector(dateTakenString)) groupSortAsc:YES];
    
    // last taken -> first taken view and mappings grouped
    self.dateTakenLastViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateTakenLastViewName database:self.database sortKey:NSStringFromSelector(@selector(dateTakenString)) sortKeyAsc:NO groupKey:NSStringFromSelector(@selector(dateTakenString)) groupSortAsc:NO];

    [self setSelectedViewMapping:self.dateTakenLastViewMapping];
}

@end
