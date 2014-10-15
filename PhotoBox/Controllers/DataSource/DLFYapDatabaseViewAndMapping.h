//
//  YapDatabaseViewAndMapping.h
//  Delightful
//
//  Created by  on 9/29/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <YapDatabaseView.h>
#import <YapDatabase.h>

@interface DLFYapDatabaseViewAndMapping : NSObject

@property (nonatomic, strong) NSString *collection;
@property (nonatomic, strong) YapDatabaseViewMappings *mapping;
@property (nonatomic, strong) YapDatabaseView *view;
@property (nonatomic, strong) NSString *sortKey;
@property (nonatomic, strong) NSString *groupKey;
@property (nonatomic, assign) BOOL sortKeyAscending;
@property (nonatomic, assign) BOOL groupSortAscending;

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

+ (DLFYapDatabaseViewAndMapping *)ungroupedViewMappingFromViewMapping:(DLFYapDatabaseViewAndMapping *)viewMappingSource database:(YapDatabase *)database;

@end
