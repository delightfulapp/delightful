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
}

- (void)setDefaultMapping {
    if (self.filterBlock) {
        if (!self.inCollectionDateUploadedLastViewMapping) {
            self.inCollectionDateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateUploadedLastViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock];
        }
        if (!self.inCollectionFlattenedDateUploadedLastViewMapping) {
            [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedLastViewName] database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                self.inCollectionFlattenedDateUploadedLastViewMapping = viewMapping;
            }];
        }
        [self setSelectedViewMapping:self.inCollectionDateUploadedLastViewMapping];
    }
    
}

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending {
    [self sortBy:sortBy ascending:ascending completion:nil];
}

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending completion:(void (^)())completion {
    if (sortBy == PhotosSortKeyDateUploaded) {
        if (ascending) {
            if (!self.inCollectionDateUploadedFirstViewMapping) {
                if (!completion) {
                    self.inCollectionDateUploadedFirstViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateUploadedFirstViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:YES filterBlock:self.filterBlock];
                    [self setSelectedViewMapping:self.inCollectionDateUploadedFirstViewMapping];
                } else {
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateUploadedFirstViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:YES filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionDateUploadedFirstViewMapping = viewMapping;
                        [self setSelectedViewMapping:self.inCollectionDateUploadedFirstViewMapping];
                        completion();
                    }];
                }
                
            }
            if (!self.inCollectionFlattenedDateUploadedFirstViewMapping) {
                [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedFirstViewName] database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                    self.inCollectionFlattenedDateUploadedFirstViewMapping = viewMapping;
                }];
            }
        } else {
            if (!self.inCollectionDateUploadedLastViewMapping) {
                if (!completion) {
                    self.inCollectionDateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateUploadedLastViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock];
                    [self setSelectedViewMapping:self.inCollectionDateUploadedLastViewMapping];
                } else {
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateUploadedLastViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionDateUploadedLastViewMapping = viewMapping;
                        [self setSelectedViewMapping:self.inCollectionDateUploadedLastViewMapping];
                        completion();
                    }];
                }
                
            }
            if (!self.inCollectionFlattenedDateUploadedLastViewMapping) {
                [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedLastViewName] database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                    self.inCollectionFlattenedDateUploadedLastViewMapping = viewMapping;
                }];
            }
        }
    } else if (sortBy == PhotosSortKeyDateTaken) {
        if (ascending) {
            if (!completion) {
                if (!self.inCollectionDateTakenFirstViewMapping) {
                    self.inCollectionDateTakenFirstViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateTakenFirstViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:YES filterBlock:self.filterBlock];
                    [self setSelectedViewMapping:self.inCollectionDateTakenFirstViewMapping];
                }
            } else {
                [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateTakenFirstViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:YES filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                    self.inCollectionDateTakenFirstViewMapping = viewMapping;
                    [self setSelectedViewMapping:self.inCollectionDateTakenFirstViewMapping];
                    completion();
                }];
            }
            
            if (!self.inCollectionFlattenedDateTakenFirstViewMapping) {
                [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:dateTakenFirstViewName] database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                    self.inCollectionFlattenedDateTakenFirstViewMapping = viewMapping;
                }];
            }
        } else {
            if (!self.inCollectionDateTakenLastViewMapping) {
                if (!completion) {
                    self.inCollectionDateTakenLastViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateTakenLastViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock];
                    [self setSelectedViewMapping:self.inCollectionDateTakenLastViewMapping];
                } else {
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateTakenLastViewName database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionDateTakenLastViewMapping = viewMapping;
                        [self setSelectedViewMapping:self.inCollectionDateTakenLastViewMapping];
                        completion();
                    }];
                }
            }
            if (!self.inCollectionFlattenedDateTakenLastViewMapping) {
                [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:dateTakenLastViewName] database:self.database collection:photosCollectionName isPersistent:YES filterName:self.filterName groupSortAsc:NO filterBlock:self.filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                    self.inCollectionFlattenedDateTakenLastViewMapping = viewMapping;
                }];
            }
        }
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
