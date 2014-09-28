//
//  YapDatabaseViewAndMapping.m
//  Delightful
//
//  Created by  on 9/29/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DLFYapDatabaseViewAndMapping.h"

@implementation DLFYapDatabaseViewAndMapping

+ (DLFYapDatabaseViewAndMapping *)databaseViewAndMappingForKeyToCompare:(NSString *)keyToCompare database:(YapDatabase *)database viewName:(NSString *)viewName asc:(BOOL)ascending grouped:(BOOL)grouped {
    YapDatabaseViewBlockType groupingBlockType = YapDatabaseViewBlockTypeWithObject;
    YapDatabaseViewGroupingWithObjectBlock groupingBlock = (grouped)? ^NSString *(NSString *collection, NSString *key, id object) {
        return [[object valueForKey:keyToCompare] description];
    }:nil;
    YapDatabaseViewBlockType sortingBlockType = YapDatabaseViewBlockTypeWithObject;
    YapDatabaseViewSortingWithObjectBlock sortingBlock = ^NSComparisonResult(NSString *group,
                                                                             NSString *collection1, NSString *key1, id obj1,
                                                                             NSString *collection2, NSString *key2, id obj2){
        return (ascending)?[[obj1 valueForKey:keyToCompare] compare:[obj2 valueForKey:keyToCompare]]:[[obj2 valueForKey:keyToCompare] compare:[obj1 valueForKey:keyToCompare]];
    };
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
                                                         groupingBlockType:groupingBlockType
                                                              sortingBlock:sortingBlock
                                                          sortingBlockType:sortingBlockType];
    [database registerExtension:view withName:viewName];
    
    YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
        return YES;
    } sortBlock:^NSComparisonResult(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction) {
        return (ascending)?[group1 compare:group2]:[group2 compare:group1];
    } view:viewName];
    
    DLFYapDatabaseViewAndMapping *returnObject = [[DLFYapDatabaseViewAndMapping alloc] init];
    returnObject.view = view;
    returnObject.mapping = mappings;
    
    return returnObject;
}

@end
