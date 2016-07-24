//
//  GroupedPhotosDataSource.m
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "GroupedPhotosDataSource.h"
#import "Photo.h"
#import "DLFDatabaseManager.h"
#import "DLFYapDatabaseViewAndMapping.h"
#import "SortingConstants.h"
#import "SortTableViewController.h"

NSString *const dateUploadedLastViewName = @"date-uploaded-last-photos";
NSString *const dateTakenLastViewName = @"date-taken-last-photos";
NSString *const dateUploadedFirstViewName = @"date-uploaded-first-photos";
NSString *const dateTakenFirstViewName = @"date-taken-first-photos";

@interface GroupedPhotosDataSource ()

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *dateUploadedLastViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *dateUploadedFirstViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *dateTakenLastViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *dateTakenFirstViewMapping;

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *flattenedDateUploadedLastViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *flattenedDateUploadedFirstViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *flattenedDateTakenLastViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *flattenedDateTakenFirstViewMapping;

@end

@implementation GroupedPhotosDataSource

- (void)setupMapping {
    // last uploaded -> first uploaded view and mappings grouped
    self.dateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateUploadedLastViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateUploaded)) sortKeyAsc:NO groupKey:NSStringFromSelector(@selector(dateUploadedString)) groupSortAsc:NO];
    
    // first uploaded -> last uploaded view and mappings grouped
    self.dateUploadedFirstViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateUploadedFirstViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateUploaded)) sortKeyAsc:YES groupKey:NSStringFromSelector(@selector(dateUploadedString)) groupSortAsc:YES];
    
    // first taken -> last taken view and mappings grouped
    self.dateTakenFirstViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateTakenFirstViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateTaken)) sortKeyAsc:YES groupKey:NSStringFromSelector(@selector(dateTakenString)) groupSortAsc:YES];
    
    // last taken -> first taken view and mappings grouped
    self.dateTakenLastViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateTakenLastViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateTaken)) sortKeyAsc:NO groupKey:NSStringFromSelector(@selector(dateTakenString)) groupSortAsc:NO];
    
    [DLFYapDatabaseViewAndMapping asyncUngroupedViewMappingFromViewMapping:self.dateUploadedLastViewMapping database:self.database completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
        CLS_LOG(@"%@ created", viewMapping.mapping.view);
        self.flattenedDateUploadedLastViewMapping = viewMapping;
    }];
    [DLFYapDatabaseViewAndMapping asyncUngroupedViewMappingFromViewMapping:self.dateUploadedFirstViewMapping database:self.database completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
        CLS_LOG(@"%@ created", viewMapping.mapping.view);
        self.flattenedDateUploadedFirstViewMapping = viewMapping;
    }];
    [DLFYapDatabaseViewAndMapping asyncUngroupedViewMappingFromViewMapping:self.dateTakenFirstViewMapping database:self.database completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
        CLS_LOG(@"%@ created", viewMapping.mapping.view);
        self.flattenedDateTakenFirstViewMapping = viewMapping;
    }];
    [DLFYapDatabaseViewAndMapping asyncUngroupedViewMappingFromViewMapping:self.dateTakenLastViewMapping database:self.database completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
        CLS_LOG(@"%@ created", viewMapping.mapping.view);
        self.flattenedDateTakenLastViewMapping = viewMapping;
    }];
}

- (void)setDefaultMapping {
    [self setSelectedViewMapping:self.dateUploadedLastViewMapping];
}

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending {
    [self sortBy:sortBy ascending:ascending completion:nil];
}

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending completion:(void (^)())completion {
    if (sortBy == PhotosSortKeyDateUploaded) {
        [self setSelectedViewMapping:(ascending)?self.dateUploadedFirstViewMapping:self.dateUploadedLastViewMapping];
    } else if (sortBy == PhotosSortKeyDateTaken) {
        [self setSelectedViewMapping:(ascending)?self.dateTakenFirstViewMapping:self.dateTakenLastViewMapping];
    }
    if (completion) completion();
}

- (DLFYapDatabaseViewAndMapping *)selectedFlattenedViewMapping {
    if (self.selectedViewMapping == self.dateTakenFirstViewMapping) {
        return self.flattenedDateTakenFirstViewMapping;
    } else if (self.selectedViewMapping == self.dateTakenLastViewMapping) {
        return self.flattenedDateTakenLastViewMapping;
    } else if (self.selectedViewMapping == self.dateUploadedFirstViewMapping) {
        return self.flattenedDateUploadedFirstViewMapping;
    } else if (self.selectedViewMapping == self.dateUploadedLastViewMapping) {
        return self.flattenedDateUploadedLastViewMapping;
    }
    return nil;
}

@end
