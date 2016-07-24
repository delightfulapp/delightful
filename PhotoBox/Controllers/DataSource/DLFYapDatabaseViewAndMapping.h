//
//  YapDatabaseViewAndMapping.h
//  Delightful
//
//  Created by  on 9/29/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YapDatabaseView.h"
#import "YapDatabase.h"

@interface DLFYapDatabaseViewAndMapping : NSObject

@property (nonatomic, strong) NSString *collection;
@property (nonatomic, strong) YapDatabaseViewMappings *mapping;
@property (nonatomic, strong) YapDatabaseView *view;
@property (nonatomic, strong) NSString *viewName;
@property (nonatomic, strong) NSString *sortKey;
@property (nonatomic, strong) NSString *groupKey;
@property (nonatomic, assign) BOOL sortKeyAscending;
@property (nonatomic, assign) BOOL groupSortAscending;
@property (nonatomic, copy) BOOL (^filterBlock)(NSString *collection, NSString *key, id object);
@property (nonatomic, assign) BOOL isPersistent;

+ (NSString *)flattenedViewName:(NSString *)viewName;

+ (NSString *)filteredViewNameFromParentViewName:(NSString *)parentViewName filterName:(NSString *)filterName;

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)collection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)ascending;

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)collection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)ascending
                                                 groupKey:(NSString *)groupKey
                                             groupSortAsc:(BOOL)ascending;

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)collection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)ascending
                                             isPersistent:(BOOL)isPersistent
                                              filterBlock:(BOOL(^)(NSString *collection, NSString *key, id object))filterBlock;

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)collection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)sortKeyAsc
                                                 groupKey:(NSString *)groupKey
                                             groupSortAsc:(BOOL)groupSortAsc
                                             isPersistent:(BOOL)isPersistent
                                              filterBlock:(BOOL(^)(NSString *collection, NSString *key, id object))filterBlock;


+ (DLFYapDatabaseViewAndMapping *)filteredViewMappingFromViewName:(NSString *)fromViewName
                                                         database:(YapDatabase *)database
                                                       collection:(NSString *)collection
                                                     isPersistent:(BOOL)isPersistent
                                        skipInitialViewPopulation:(BOOL)skipInitialViewPopulation
                                                       filterName:(NSString *)filterName
                                                     groupSortAsc:(BOOL)groupSortAscending
                                                      filterBlock:(BOOL (^)(NSString *, NSString *, id))filterBlock;


+ (DLFYapDatabaseViewAndMapping *)ungroupedViewMappingFromViewMapping:(DLFYapDatabaseViewAndMapping *)viewMappingSource
                                                             database:(YapDatabase *)database;

+ (void)asyncViewMappingWithViewName:(NSString *)viewName
                          collection:(NSString *)collection
                            database:(YapDatabase *)database
                             sortKey:(NSString *)sortKey
                          sortKeyAsc:(BOOL)ascending
                          completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock;

+ (void)asyncViewMappingWithViewName:(NSString *)viewName
                          collection:(NSString *)collection
                            database:(YapDatabase *)database
                             sortKey:(NSString *)sortKey
                          sortKeyAsc:(BOOL)ascending
                            groupKey:(NSString *)groupKey
                        groupSortAsc:(BOOL)ascending
                          completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock;

+ (void)asyncViewMappingWithViewName:(NSString *)viewName
                     collection:(NSString *)collection
                       database:(YapDatabase *)database
                        sortKey:(NSString *)sortKey
                     sortKeyAsc:(BOOL)ascending
                   isPersistent:(BOOL)isPersistent
                    filterBlock:(BOOL(^)(NSString *collection, NSString *key, id object))filterBlock
                     completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock;

+ (void)asyncViewMappingWithViewName:(NSString *)viewName
                     collection:(NSString *)collection
                       database:(YapDatabase *)database
                        sortKey:(NSString *)sortKey
                     sortKeyAsc:(BOOL)sortKeyAsc
                       groupKey:(NSString *)groupKey
                   groupSortAsc:(BOOL)groupSortAsc
                   isPersistent:(BOOL)isPersistent
                    filterBlock:(BOOL(^)(NSString *collection, NSString *key, id object))filterBlock
                     completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock;

+ (void)asyncFilteredViewMappingFromViewName:(NSString *)fromViewName
                                    database:(YapDatabase *)database
                                  collection:(NSString *)collection
                                isPersistent:(BOOL)isPersistent
                   skipInitialViewPopulation:(BOOL)skipInitialViewPopulation
                                  filterName:(NSString *)filterName
                                groupSortAsc:(BOOL)groupSortAscending
                                 filterBlock:(BOOL (^)(NSString *collection, NSString *key, id object))filterBlock
                                  completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock;

+ (void)asyncUngroupedViewMappingFromViewMapping:(DLFYapDatabaseViewAndMapping *)viewMappingSource
                                        database:(YapDatabase *)database
                                      completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock;

@end
