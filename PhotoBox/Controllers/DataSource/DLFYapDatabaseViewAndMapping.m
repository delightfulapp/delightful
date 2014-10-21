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
                                               collection:(NSString *)collection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)ascending
                                               completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    return [self.class viewMappingWithViewName:viewName collection:collection database:database sortKey:sortKey sortKeyAsc:ascending groupKey:nil groupSortAsc:NO completion:completionBlock];
}

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)collection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)ascending {
    return [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewName collection:collection database:database sortKey:sortKey sortKeyAsc:ascending completion:nil];
}

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)aCollection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)sortKeyAscending
                                                 groupKey:(NSString *)groupKey
                                             groupSortAsc:(BOOL)groupSortAscending {
    return [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewName collection:aCollection database:database sortKey:sortKey sortKeyAsc:sortKeyAscending groupKey:groupKey groupSortAsc:groupSortAscending completion:nil];
}

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)aCollection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)sortKeyAscending
                                                 groupKey:(NSString *)groupKey
                                             groupSortAsc:(BOOL)groupSortAscending
                                               completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock{
    
    YapDatabaseViewGroupingWithObjectBlock groupingBlock = ^NSString *(NSString *collection, NSString *key, id object) {
        if (![collection isEqualToString:aCollection]) {
            return nil;
        }
        return (groupKey && [aCollection isEqualToString:collection])?[[object valueForKey:groupKey] description]:@"";
    };
    YapDatabaseViewSortingWithObjectBlock sortingBlock = ^NSComparisonResult(NSString *group,
                                                                             NSString *collection1, NSString *key1, id obj1,
                                                                             NSString *collection2, NSString *key2, id obj2){
        if (![collection1 isEqualToString:aCollection] || ![collection2 isEqualToString:aCollection]) {
            return NSOrderedSame;
        }
        return (sortKeyAscending)?[[obj1 valueForKey:sortKey] compare:[obj2 valueForKey:sortKey]]:[[obj2 valueForKey:sortKey] compare:[obj1 valueForKey:sortKey]];
    };
    
    YapDatabaseViewGrouping *grouping = [YapDatabaseViewGrouping withObjectBlock:groupingBlock];
    YapDatabaseViewSorting *sorting = [YapDatabaseViewSorting withObjectBlock:sortingBlock];
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    [options setIsPersistent:YES];
    YapWhitelistBlacklist *whitelist = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:aCollection]];
    [options setAllowedCollections:whitelist];
    
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGrouping:grouping sorting:sorting versionTag:@"1" options:options];
    
    DLFYapDatabaseViewAndMapping * (^viewMappingInit)() = ^DLFYapDatabaseViewAndMapping*() {
        YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
            return (group)?YES:NO;
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
        returnObject.collection = aCollection;
        
        return returnObject;
    };

    
    if (!completionBlock) {
        [database registerExtension:view withName:viewName];
        return viewMappingInit();
    } else {
        [database asyncRegisterExtension:view withName:viewName completionBlock:^(BOOL ready) {
            if (ready) {
                DLFYapDatabaseViewAndMapping *returnObject = viewMappingInit();
                completionBlock(returnObject);
            }
        }];
    }
    return nil;
}

+ (DLFYapDatabaseViewAndMapping *)ungroupedViewMappingFromViewMapping:(DLFYapDatabaseViewAndMapping *)viewMappingSource database:(YapDatabase *)database {
    return [DLFYapDatabaseViewAndMapping ungroupedViewMappingFromViewMapping:viewMappingSource database:database completion:nil];
}

+ (DLFYapDatabaseViewAndMapping *)ungroupedViewMappingFromViewMapping:(DLFYapDatabaseViewAndMapping *)viewMappingSource database:(YapDatabase *)database completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    return [DLFYapDatabaseViewAndMapping viewMappingWithViewName:[NSString stringWithFormat:@"%@-flattened", viewMappingSource.mapping.view] collection:viewMappingSource.collection database:database sortKey:viewMappingSource.sortKey sortKeyAsc:viewMappingSource.sortKeyAscending completion:completionBlock];
}

+ (void)asyncViewMappingWithViewName:(NSString *)viewName
                          collection:(NSString *)collection
                            database:(YapDatabase *)database
                             sortKey:(NSString *)sortKey
                          sortKeyAsc:(BOOL)ascending
                          completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewName collection:collection database:database sortKey:sortKey sortKeyAsc:ascending groupKey:nil groupSortAsc:NO completion:completionBlock];
}

+ (void)asyncViewMappingWithViewName:(NSString *)viewName
                          collection:(NSString *)collection
                            database:(YapDatabase *)database
                             sortKey:(NSString *)sortKey
                          sortKeyAsc:(BOOL)sortKeyAsc
                            groupKey:(NSString *)groupKey
                        groupSortAsc:(BOOL)groupSortAsc
                          completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewName collection:collection database:database sortKey:sortKey sortKeyAsc:sortKeyAsc groupKey:groupKey groupSortAsc:groupSortAsc completion:completionBlock];
}

+ (void)asyncUngroupedViewMappingFromViewMapping:(DLFYapDatabaseViewAndMapping *)viewMappingSource
                                        database:(YapDatabase *)database
                                      completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    [DLFYapDatabaseViewAndMapping ungroupedViewMappingFromViewMapping:viewMappingSource database:database completion:completionBlock];
}

@end
