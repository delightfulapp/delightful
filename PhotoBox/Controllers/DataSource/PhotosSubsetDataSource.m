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
        
        void (^saveViewBlock)() = ^void() {
            [[DLFDatabaseManager manager] saveFilteredViewName:[DLFYapDatabaseViewAndMapping filteredViewNameFromParentViewName:dateUploadedLastViewName filterName:self.filterName]
                                                  fromViewName:dateUploadedLastViewName
                                                    filterName:self.filterName
                                                  groupSortAsc:NO objectKey:self.objectKey
                                                     filterKey:self.filterKey];
        };
        
        if (!self.inCollectionDateUploadedLastViewMapping) {
            self.inCollectionDateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateUploadedLastViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock];
            saveViewBlock();
        }
        if (!self.inCollectionFlattenedDateUploadedLastViewMapping) {
            [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedLastViewName] database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                self.inCollectionFlattenedDateUploadedLastViewMapping = viewMapping;
                saveViewBlock();
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
            void (^saveViewBlock)() = ^void() {
                [[DLFDatabaseManager manager] saveFilteredViewName:[DLFYapDatabaseViewAndMapping filteredViewNameFromParentViewName:dateUploadedFirstViewName filterName:self.filterName]
                                                      fromViewName:dateUploadedFirstViewName
                                                        filterName:self.filterName
                                                      groupSortAsc:YES
                                                         objectKey:self.objectKey
                                                         filterKey:self.filterKey];
            };
            
            if (!self.inCollectionDateUploadedFirstViewMapping) {
                if (!completion) {
                    self.inCollectionDateUploadedFirstViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateUploadedFirstViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:YES filterBlock:filterBlock];
                    saveViewBlock();
                    [self setSelectedViewMapping:self.inCollectionDateUploadedFirstViewMapping];
                } else {
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateUploadedFirstViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:YES filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionDateUploadedFirstViewMapping = viewMapping;
                        saveViewBlock();
                        [self setSelectedViewMapping:self.inCollectionDateUploadedFirstViewMapping];
                        completion();
                    }];
                }
                
            }
            if (!self.inCollectionFlattenedDateUploadedFirstViewMapping) {
                NSString *flattenedParentViewName = [DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedFirstViewName];
                [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:flattenedParentViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                    self.inCollectionFlattenedDateUploadedFirstViewMapping = viewMapping;
                    
                    [[DLFDatabaseManager manager] saveFilteredViewName:[DLFYapDatabaseViewAndMapping filteredViewNameFromParentViewName:flattenedParentViewName filterName:self.filterName]
                                                          fromViewName:dateUploadedFirstViewName
                                                            filterName:self.filterName
                                                          groupSortAsc:NO
                                                             objectKey:self.objectKey
                                                             filterKey:self.filterKey];
                }];
            }
        } else {
            void (^saveViewBlock)() = ^void() {
                [[DLFDatabaseManager manager] saveFilteredViewName:[DLFYapDatabaseViewAndMapping filteredViewNameFromParentViewName:dateUploadedLastViewName filterName:self.filterName]
                                                      fromViewName:dateUploadedLastViewName
                                                        filterName:self.filterName
                                                      groupSortAsc:NO
                                                         objectKey:self.objectKey
                                                         filterKey:self.filterKey];
            };
            
            if (!self.inCollectionDateUploadedLastViewMapping) {
                if (!completion) {
                    self.inCollectionDateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateUploadedLastViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock];
                    saveViewBlock();
                    [self setSelectedViewMapping:self.inCollectionDateUploadedLastViewMapping];
                } else {
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateUploadedLastViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionDateUploadedLastViewMapping = viewMapping;
                        saveViewBlock();
                        [self setSelectedViewMapping:self.inCollectionDateUploadedLastViewMapping];
                        completion();
                    }];
                }
                
            }
            if (!self.inCollectionFlattenedDateUploadedLastViewMapping) {
                NSString *flattenedParentViewName = [DLFYapDatabaseViewAndMapping flattenedViewName:dateUploadedLastViewName];
                [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:flattenedParentViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                    self.inCollectionFlattenedDateUploadedLastViewMapping = viewMapping;
                    
                    [[DLFDatabaseManager manager] saveFilteredViewName:[DLFYapDatabaseViewAndMapping filteredViewNameFromParentViewName:flattenedParentViewName filterName:self.filterName]
                                                          fromViewName:dateUploadedLastViewName
                                                            filterName:self.filterName
                                                          groupSortAsc:NO
                                                             objectKey:self.objectKey
                                                             filterKey:self.filterKey];
                }];
            }
        }
    } else if (sortBy == PhotosSortKeyDateTaken) {
        if (ascending) {
            void (^saveViewBlock)() = ^void() {
                [[DLFDatabaseManager manager] saveFilteredViewName:[DLFYapDatabaseViewAndMapping filteredViewNameFromParentViewName:dateTakenFirstViewName filterName:self.filterName]
                                                      fromViewName:dateTakenFirstViewName
                                                        filterName:self.filterName
                                                      groupSortAsc:YES
                                                         objectKey:self.objectKey
                                                         filterKey:self.filterKey];
            };
            
            if (!completion) {
                if (!self.inCollectionDateTakenFirstViewMapping) {
                    self.inCollectionDateTakenFirstViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateTakenFirstViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:YES filterBlock:filterBlock];
                    saveViewBlock();
                    [self setSelectedViewMapping:self.inCollectionDateTakenFirstViewMapping];
                }
            } else {
                [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateTakenFirstViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:YES filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                    self.inCollectionDateTakenFirstViewMapping = viewMapping;
                    saveViewBlock();
                    [self setSelectedViewMapping:self.inCollectionDateTakenFirstViewMapping];
                    completion();
                }];
            }
            
            if (!self.inCollectionFlattenedDateTakenFirstViewMapping) {
                NSString *flattenedParentViewName = [DLFYapDatabaseViewAndMapping flattenedViewName:dateTakenFirstViewName];
                [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:flattenedParentViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                    self.inCollectionFlattenedDateTakenFirstViewMapping = viewMapping;
                    
                    [[DLFDatabaseManager manager] saveFilteredViewName:[DLFYapDatabaseViewAndMapping filteredViewNameFromParentViewName:flattenedParentViewName filterName:self.filterName]
                                                          fromViewName:dateTakenFirstViewName
                                                            filterName:self.filterName
                                                          groupSortAsc:NO
                                                             objectKey:self.objectKey
                                                             filterKey:self.filterKey];
                }];
            }
        } else {
            void (^saveViewBlock)() = ^void() {
                [[DLFDatabaseManager manager] saveFilteredViewName:[DLFYapDatabaseViewAndMapping filteredViewNameFromParentViewName:dateTakenLastViewName filterName:self.filterName]
                                                      fromViewName:dateTakenLastViewName
                                                        filterName:self.filterName
                                                      groupSortAsc:NO
                                                         objectKey:self.objectKey
                                                         filterKey:self.filterKey];
            };
            
            if (!self.inCollectionDateTakenLastViewMapping) {
                if (!completion) {
                    self.inCollectionDateTakenLastViewMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:dateTakenLastViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock];
                    saveViewBlock();
                    [self setSelectedViewMapping:self.inCollectionDateTakenLastViewMapping];
                } else {
                    [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:dateTakenLastViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                        self.inCollectionDateTakenLastViewMapping = viewMapping;
                        saveViewBlock();
                        [self setSelectedViewMapping:self.inCollectionDateTakenLastViewMapping];
                        completion();
                    }];
                }
            }
            if (!self.inCollectionFlattenedDateTakenLastViewMapping) {
                NSString *flattenedParentViewName = [DLFYapDatabaseViewAndMapping flattenedViewName:dateTakenLastViewName];
                [DLFYapDatabaseViewAndMapping asyncFilteredViewMappingFromViewName:flattenedParentViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:self.filterName groupSortAsc:NO filterBlock:filterBlock completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
                    self.inCollectionFlattenedDateTakenLastViewMapping = viewMapping;
                    
                    [[DLFDatabaseManager manager] saveFilteredViewName:[DLFYapDatabaseViewAndMapping filteredViewNameFromParentViewName:flattenedParentViewName filterName:self.filterName]
                                                          fromViewName:dateTakenLastViewName
                                                            filterName:self.filterName
                                                          groupSortAsc:NO
                                                             objectKey:self.objectKey
                                                             filterKey:self.filterKey];
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
