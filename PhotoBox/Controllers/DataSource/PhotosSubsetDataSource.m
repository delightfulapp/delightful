//
//  PhotosinCollectionDataSource.m
//  Delightful
//
//  Created by  on 10/22/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
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

@property (nonatomic, copy) NSString *filterName;
@property (nonatomic, copy) NSString *filterKey;
@property (nonatomic, copy) NSString *objectKey;

@end

@implementation PhotosSubsetDataSource

- (void)setFilterName:(NSString *)filterName objectKey:(NSString *)objectKey filterKey:(NSString *)filterKey {
    self.filterName = filterName;
    self.filterKey = filterKey;
    self.objectKey = objectKey;
    [self setupMapping];
    [self setDefaultMapping];
}

- (void)setupMapping {
}

- (void)setDefaultMapping {
    if (self.objectKey && self.filterName && self.filterKey) {
        BOOL (^filterBlock)(NSString *collection, NSString *key, Photo *object) = ^BOOL(NSString *collection, NSString *key, Photo *object) {
            return [[object valueForKey:self.objectKey] containsObject:self.filterKey];
        };
        
        
        if (!self.inCollectionDateUploadedLastViewMapping) {
            self.inCollectionDateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping
                                                            filteredViewMappingFromViewName:dateUploadedLastViewName
                                                            database:self.database
                                                            collection:photosCollectionName
                                                            isPersistent:YES
                                                            skipInitialViewPopulation:YES
                                                            filterName:self.filterName
                                                            groupSortAsc:NO
                                                            filterBlock:filterBlock];
            [self saveFilteredViewName:self.inCollectionDateUploadedLastViewMapping.viewName fromViewName:dateUploadedLastViewName];
        }
        if (!self.inCollectionFlattenedDateUploadedLastViewMapping) {
            NSString *fromViewName = [DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedLastViewName];
            [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:fromViewName
                                                                      database:self.database
                                                                    collection:photosCollectionName
                                                                  isPersistent:YES
                                                     skipInitialViewPopulation:YES
                                                                    filterName:self.filterName
                                                                  groupSortAsc:NO
                                                                   filterBlock:filterBlock
                                                                    completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                self.inCollectionFlattenedDateUploadedLastViewMapping = viewMapping;
                [self saveFilteredViewName:self.inCollectionFlattenedDateUploadedLastViewMapping.viewName fromViewName:fromViewName];
                                                                    }];
        }
        [self setSelectedViewMapping:self.inCollectionDateUploadedLastViewMapping];
    }
}

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending {
    [self sortBy:sortBy ascending:ascending completion:nil];
}

- (void)sortBy:(PhotosSortKey)sortBy ascending:(BOOL)ascending completion:(void (^)())completion {
    BOOL (^filterBlock)(NSString *collection, NSString *key, Photo *object) = ^BOOL(NSString *collection, NSString *key, Photo *object) {
        return [[object valueForKey:self.objectKey] containsObject:self.filterKey];
    };
    
    if (sortBy == PhotosSortKeyDateUploaded) {
        if (ascending) {
            void (^flattenedViewRegistration)() = ^void() {
                if (!self.inCollectionFlattenedDateUploadedFirstViewMapping) {
                    NSString *fromViewName = [DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedFirstViewName];
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:fromViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionFlattenedDateUploadedFirstViewMapping = viewMapping;
                        [self setSelectedViewMapping:self.inCollectionDateUploadedFirstViewMapping];
                        [self saveFilteredViewName:self.inCollectionFlattenedDateUploadedFirstViewMapping.viewName fromViewName:fromViewName];
                    }];
                }
            };

            
            if (!self.inCollectionDateUploadedFirstViewMapping) {
                if (!completion) {
                    self.inCollectionDateUploadedFirstViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateUploadedFirstViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:YES filterBlock:filterBlock];
                    [self saveFilteredViewName:self.inCollectionDateUploadedFirstViewMapping.viewName fromViewName:dateUploadedFirstViewName];
                    flattenedViewRegistration();
                } else {
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateUploadedFirstViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:YES filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionDateUploadedFirstViewMapping = viewMapping;
                        [self saveFilteredViewName:self.inCollectionDateUploadedFirstViewMapping.viewName fromViewName:dateUploadedFirstViewName];
                        flattenedViewRegistration();
                        completion();
                    }];
                }
            } else {
                [self setSelectedViewMapping:self.inCollectionDateUploadedFirstViewMapping];
            }
        } else {
            void (^flattenedViewRegistration)() = ^void() {
                if (!self.inCollectionFlattenedDateUploadedLastViewMapping) {
                    NSString *flattenedParentViewName = [DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedLastViewName];
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:flattenedParentViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionFlattenedDateUploadedLastViewMapping = viewMapping;
                        [self setSelectedViewMapping:self.inCollectionDateUploadedLastViewMapping];
                        [self saveFilteredViewName:self.inCollectionFlattenedDateUploadedLastViewMapping.viewName fromViewName:flattenedParentViewName];
                    }];
                }
            };
            
            if (!self.inCollectionDateUploadedLastViewMapping) {
                if (!completion) {
                    self.inCollectionDateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateUploadedLastViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock];
                    [self saveFilteredViewName:self.inCollectionDateUploadedLastViewMapping.viewName fromViewName:dateUploadedLastViewName];
                    flattenedViewRegistration();
                } else {
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateUploadedLastViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionDateUploadedLastViewMapping = viewMapping;
                        [self saveFilteredViewName:self.inCollectionDateUploadedLastViewMapping.viewName fromViewName:dateUploadedLastViewName];
                        flattenedViewRegistration();
                        completion();
                    }];
                }
            } else {
                [self setSelectedViewMapping:self.inCollectionDateUploadedLastViewMapping];
            }
            
        }
    } else if (sortBy == PhotosSortKeyDateTaken) {
        if (ascending) {
            void (^flattenedViewRegistration)() = ^void() {
                if (!self.inCollectionFlattenedDateTakenFirstViewMapping) {
                    NSString *flattenedParentViewName = [DLFYapDatabaseViewAndMapping flattenedViewName:dateTakenFirstViewName];
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:flattenedParentViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionFlattenedDateTakenFirstViewMapping = viewMapping;
                        [self setSelectedViewMapping:self.inCollectionDateTakenFirstViewMapping];
                        [self saveFilteredViewName:self.inCollectionFlattenedDateTakenFirstViewMapping.viewName fromViewName:flattenedParentViewName];
                    }];
                }
            };
            
            if (!self.inCollectionDateTakenFirstViewMapping) {
                if (!completion) {
                    self.inCollectionDateTakenFirstViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateTakenFirstViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:YES filterBlock:filterBlock];
                    [self saveFilteredViewName:self.inCollectionDateTakenFirstViewMapping.viewName fromViewName:dateTakenFirstViewName];
                    flattenedViewRegistration();
                } else {
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateTakenFirstViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:YES filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionDateTakenFirstViewMapping = viewMapping;
                        [self saveFilteredViewName:self.inCollectionDateTakenFirstViewMapping.viewName fromViewName:dateTakenFirstViewName];
                        flattenedViewRegistration();
                        completion();
                    }];
                }
            } else {
                [self setSelectedViewMapping:self.inCollectionDateTakenFirstViewMapping];
            }
        } else {
            void (^flattenedViewRegistration)() = ^void() {
                if (!self.inCollectionFlattenedDateTakenLastViewMapping) {
                    NSString *flattenedParentViewName = [DLFYapDatabaseViewAndMapping flattenedViewName:dateTakenLastViewName];
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:flattenedParentViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionFlattenedDateTakenLastViewMapping = viewMapping;
                        [self setSelectedViewMapping:self.inCollectionDateTakenLastViewMapping];
                        [self saveFilteredViewName:self.inCollectionFlattenedDateTakenLastViewMapping.viewName fromViewName:flattenedParentViewName];
                    }];
                }
            };
            
            if (!self.inCollectionDateTakenLastViewMapping) {
                if (!completion) {
                    self.inCollectionDateTakenLastViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateTakenLastViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock];
                    [self saveFilteredViewName:self.inCollectionDateTakenLastViewMapping.viewName fromViewName:dateTakenLastViewName];
                    flattenedViewRegistration();
                } else {
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateTakenLastViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionDateTakenLastViewMapping = viewMapping;
                        [self saveFilteredViewName:self.inCollectionDateTakenLastViewMapping.viewName fromViewName:dateTakenLastViewName];
                        flattenedViewRegistration();
                        completion();
                    }];
                }
            } else {
                [self setSelectedViewMapping:self.inCollectionDateTakenLastViewMapping];
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

- (void)saveFilteredViewName:(NSString *)filteredViewName fromViewName:(NSString *)fromViewName {
    [[DLFDatabaseManager manager] saveFilteredViewName:filteredViewName
                                          fromViewName:fromViewName
                                            filterName:self.filterName
                                          groupSortAsc:NO
                                             objectKey:self.objectKey
                                             filterKey:self.filterKey];
}

@end
