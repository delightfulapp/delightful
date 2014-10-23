//
//  PhotosinCollectionDataSource.m
//  Delightful
//
//  Created by  on 10/22/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosSubsetDataSource.h"

#import "Photo.h"

#import "DLFDatabaseManager.h"

#import "DLFYapDatabaseViewAndMapping.h"

NSString *inCollectionDateUploadedLastViewName = @"date-uploaded-last-photos-subset";
NSString *inCollectionDateTakenLastViewName = @"date-taken-last-photos-subset";
NSString *inCollectionDateUploadedFirstViewName = @"date-uploaded-first-photos-subset";
NSString *inCollectionDateTakenFirstViewName = @"date-taken-first-photos-subset";

@interface PhotosSubsetDataSource ()

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *inCollectionDateUploadedLastViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *inCollectionDateUploadedFirstViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *inCollectionDateTakenLastViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *inCollectionDateTakenFirstViewMapping;

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *inCollectionFlattenedDateUploadedLastViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *inCollectionFlattenedDateUploadedFirstViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *inCollectionFlattenedDateTakenLastViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *inCollectionFlattenedDateTakenFirstViewMapping;

@property (nonatomic, copy) BOOL (^filterBlock)(NSString *collection, NSString *key, id object);
@property (nonatomic, copy) NSString *filterName;

@end

@implementation PhotosSubsetDataSource

- (void)setFilterBlock:(BOOL (^)(NSString *, NSString *, id))filterBlock name:(NSString *)filterName {
    self.filterName = filterName;
    
    if (_filterBlock != filterBlock) {
        _filterBlock = [filterBlock copy];
        
        [self setupMapping];
        [self setDefaultMapping];
    }
}

- (void)setupMapping {
    [super setupMapping];
    
    if (self.filterBlock) {
        self.inCollectionDateTakenFirstViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateTakenFirstViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:YES filterBlock:self.filterBlock];
        self.inCollectionDateTakenLastViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateTakenLastViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock];
        self.inCollectionDateUploadedFirstViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateUploadedFirstViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:YES filterBlock:self.filterBlock];
        self.inCollectionDateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateUploadedLastViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock];
        
        [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:dateTakenFirstViewName] database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
            self.inCollectionFlattenedDateTakenFirstViewMapping = viewMapping;
        }];
        [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:dateTakenLastViewName] database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
            self.inCollectionFlattenedDateTakenLastViewMapping = viewMapping;
        }];
        [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedFirstViewName] database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
            self.inCollectionFlattenedDateUploadedFirstViewMapping = viewMapping;
        }];
        [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedLastViewName] database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
            self.inCollectionFlattenedDateUploadedLastViewMapping = viewMapping;
        }];
        
    }
}

- (void)setDefaultMapping {
    if (self.inCollectionDateUploadedLastViewMapping) {
        [self setSelectedViewMapping:self.inCollectionDateUploadedLastViewMapping];
    }
}

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending {
    if (sortBy == PhotosSortKeyDateUploaded) {
        [self setSelectedViewMapping:(ascending)?self.inCollectionDateUploadedFirstViewMapping:self.inCollectionDateUploadedLastViewMapping];
    } else if (sortBy == PhotosSortKeyDateTaken) {
        [self setSelectedViewMapping:(ascending)?self.inCollectionDateTakenFirstViewMapping:self.inCollectionDateTakenLastViewMapping];
    }
}

- (DLFYapDatabaseViewAndMapping *)selectedFlattenedViewMapping {
    if (self.selectedViewMapping == self.inCollectionDateTakenFirstViewMapping) {
        return self.inCollectionFlattenedDateTakenFirstViewMapping;
    } else if (self.selectedViewMapping == self.inCollectionDateTakenLastViewMapping) {
        return self.inCollectionFlattenedDateTakenLastViewMapping;
    } else if (self.selectedViewMapping == self.inCollectionDateUploadedFirstViewMapping) {
        return self.inCollectionFlattenedDateUploadedFirstViewMapping;
    } else if (self.selectedViewMapping == self.inCollectionDateUploadedLastViewMapping) {
        return self.inCollectionFlattenedDateUploadedLastViewMapping;
    }
    return nil;
}

@end
