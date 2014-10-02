//
//  YapDatabaseViewAndMapping.m
//  Delightful
//
//  Created by  on 9/29/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DLFYapDatabaseViewAndMapping.h"

@implementation DLFYapDatabaseViewAndMapping

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)ascending {
    return [self.class viewMappingWithViewName:viewName database:database sortKey:sortKey sortKeyAsc:ascending groupKey:nil groupSortAsc:NO];
}

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)sortKeyAscending
                                                 groupKey:(NSString *)groupKey
                                             groupSortAsc:(BOOL)groupSortAscending {
    YapDatabaseViewBlockType groupingBlockType = YapDatabaseViewBlockTypeWithObject;
    YapDatabaseViewGroupingWithObjectBlock groupingBlock = ^NSString *(NSString *collection, NSString *key, id object) {
        return (groupKey)?[[object valueForKey:groupKey] description]:@"";
    };
    YapDatabaseViewBlockType sortingBlockType = YapDatabaseViewBlockTypeWithObject;
    YapDatabaseViewSortingWithObjectBlock sortingBlock = ^NSComparisonResult(NSString *group,
                                                                             NSString *collection1, NSString *key1, id obj1,
                                                                             NSString *collection2, NSString *key2, id obj2){
        return (sortKeyAscending)?[[obj1 valueForKey:sortKey] compare:[obj2 valueForKey:sortKey]]:[[obj2 valueForKey:sortKey] compare:[obj1 valueForKey:sortKey]];
    };
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
                                                         groupingBlockType:groupingBlockType
                                                              sortingBlock:sortingBlock
                                                          sortingBlockType:sortingBlockType];
    [database registerExtension:view withName:viewName];
    
    YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
        return YES;
    } sortBlock:^NSComparisonResult(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction) {
        return (groupSortAscending)?[group1 compare:group2]:[group2 compare:group1];
    } view:viewName];
    
    DLFYapDatabaseViewAndMapping *returnObject = [[DLFYapDatabaseViewAndMapping alloc] init];
    returnObject.view = view;
    returnObject.mapping = mappings;
    returnObject.sortKey = sortKey;
    returnObject.sortKeyAscending = sortKeyAscending;
    returnObject.groupSortAscending = groupSortAscending;
    returnObject.groupKey = groupKey;
    
    return returnObject;
}

+ (DLFYapDatabaseViewAndMapping *)ungroupedViewMappingFromViewMapping:(DLFYapDatabaseViewAndMapping *)viewMappingSource database:(YapDatabase *)database{
    return [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewMappingSource.mapping.view database:database sortKey:viewMappingSource.sortKey sortKeyAsc:viewMappingSource.sortKeyAscending];
}

@end
