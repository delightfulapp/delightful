//
//  YapDatabaseViewAndMapping.m
//  Delightful
//
//  Created by  on 9/29/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "DLFYapDatabaseViewAndMapping.h"

#import "DLFDatabaseManager.h"

#import "YapDatabaseFilteredView.h"

@implementation DLFYapDatabaseViewAndMapping

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)collection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)ascending
                                               completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    return [self.class viewMappingWithViewName:viewName collection:collection database:database sortKey:sortKey sortKeyAsc:ascending groupKey:nil groupSortAsc:NO isPersistent:YES completion:completionBlock filterBlock:nil];
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
    return [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewName collection:aCollection database:database sortKey:sortKey sortKeyAsc:sortKeyAscending groupKey:groupKey groupSortAsc:groupSortAscending isPersistent:YES completion:nil filterBlock:nil];
}

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)collection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)ascending
                                             isPersistent:(BOOL)isPersistent
                                              filterBlock:(BOOL(^)(NSString *collection, NSString *key, id object))filterBlock {
    return [self.class viewMappingWithViewName:viewName collection:collection database:database sortKey:sortKey sortKeyAsc:ascending groupKey:nil groupSortAsc:NO isPersistent:isPersistent completion:nil filterBlock:filterBlock];
}

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)aCollection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)sortKeyAscending
                                                 groupKey:(NSString *)groupKey
                                             groupSortAsc:(BOOL)groupSortAscending
                                             isPersistent:(BOOL)isPersistent
                                              filterBlock:(BOOL(^)(NSString *collection, NSString *key, id object))filterBlock {
    return [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewName collection:aCollection database:database sortKey:sortKey sortKeyAsc:sortKeyAscending groupKey:groupKey groupSortAsc:groupSortAscending isPersistent:isPersistent completion:nil filterBlock:filterBlock];
}

+ (DLFYapDatabaseViewAndMapping *)viewMappingWithViewName:(NSString *)viewName
                                               collection:(NSString *)aCollection
                                                 database:(YapDatabase *)database
                                                  sortKey:(NSString *)sortKey
                                               sortKeyAsc:(BOOL)sortKeyAscending
                                                 groupKey:(NSString *)groupKey
                                             groupSortAsc:(BOOL)groupSortAscending
                                             isPersistent:(BOOL)isPersistent
                                               completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock
                                              filterBlock:(BOOL(^)(NSString *collection, NSString *key, id object))filterBlock {
    
    YapDatabaseViewGroupingWithObjectBlock groupingBlock = ^NSString *(NSString *collection, NSString *key, id object) {
        if (![collection isEqualToString:aCollection]) {
            return nil;
        }
        if (filterBlock) {
            BOOL include = filterBlock(collection, key, object);
            if (!include) {
                return nil;
            }
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
    [options setIsPersistent:isPersistent];
    YapWhitelistBlacklist *whitelist = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:aCollection]];
    [options setAllowedCollections:whitelist];
    [options setSkipInitialViewPopulation:YES];
    
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
        returnObject.viewName = viewName;
        returnObject.sortKey = sortKey;
        returnObject.sortKeyAscending = sortKeyAscending;
        returnObject.groupSortAscending = groupSortAscending;
        returnObject.groupKey = groupKey;
        returnObject.isPersistent = isPersistent;
        returnObject.filterBlock = filterBlock;
        returnObject.collection = aCollection;
        
        return returnObject;
    };

    if ([database registeredExtension:viewName]) {
        if (!completionBlock) {
            return viewMappingInit();
        } else {
            completionBlock(viewMappingInit());
            return nil;
        }
    }
    
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

+ (DLFYapDatabaseViewAndMapping *)filteredViewMappingFromViewName:(NSString *)fromViewName
                                                         database:(YapDatabase *)database
                                                       collection:(NSString *)collection
                                                     isPersistent:(BOOL)isPersistent
                                        skipInitialViewPopulation:(BOOL)skipInitialViewPopulation
                                                       filterName:(NSString *)filterName
                                                     groupSortAsc:(BOOL)groupSortAscending
                                                      filterBlock:(BOOL (^)(NSString *collection, NSString *key, id object))filterBlock {
    return [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:fromViewName database:database collection:collection isPersistent:isPersistent skipInitialViewPopulation:skipInitialViewPopulation groupSortAsc:groupSortAscending filterName:filterName filterBlock:filterBlock completion:nil];
}

+ (DLFYapDatabaseViewAndMapping *)filteredViewMappingFromViewName:(NSString *)fromViewName
                                                         database:(YapDatabase *)database
                                                       collection:(NSString *)collection
                                                     isPersistent:(BOOL)isPersistent
                                        skipInitialViewPopulation:(BOOL)skipInitialViewPopulation
                                                     groupSortAsc:(BOOL)groupSortAscending
                                                       filterName:(NSString *)filterName
                                                      filterBlock:(BOOL (^)(NSString *collection, NSString *key, id object))filterBlock
                                                       completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    
    YapDatabaseViewFiltering *filtering = [YapDatabaseViewFiltering withObjectBlock:^BOOL(NSString *group, NSString *collection, NSString *key, id object) {
        return filterBlock(collection, key, object);
    }];
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    [options setIsPersistent:isPersistent];
    [options setSkipInitialViewPopulation:skipInitialViewPopulation];
    YapDatabaseFilteredView *filteredView = [[YapDatabaseFilteredView alloc] initWithParentViewName:fromViewName filtering:filtering versionTag:filterName options:options];
    
    NSString *viewName = [self.class filteredViewNameFromParentViewName:fromViewName filterName:filterName];
    
    DLFYapDatabaseViewAndMapping * (^viewMappingInit)() = ^DLFYapDatabaseViewAndMapping*() {
        YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
            return (group)?YES:NO;
        } sortBlock:^NSComparisonResult(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction) {
            return groupSortAscending?[group1 compare:group2]:[group2 compare:group1];
        } view:viewName];
        
        DLFYapDatabaseViewAndMapping *returnObject = [[DLFYapDatabaseViewAndMapping alloc] init];
        returnObject.view = filteredView;
        returnObject.viewName = viewName;
        returnObject.mapping = mappings;
        returnObject.isPersistent = isPersistent;
        returnObject.filterBlock = filterBlock;
        returnObject.collection = collection;
        
        return returnObject;
    };
    
    if ([database registeredExtension:viewName]) {
        if (!completionBlock) {
            return viewMappingInit();
        } else {
            DLFYapDatabaseViewAndMapping *returnObject = viewMappingInit();
            completionBlock(returnObject);
            return nil;
        }
    }
    
    CLS_LOG(@"Registering new view %@", viewName);
    if (!completionBlock) {
        [database registerExtension:filteredView withName:viewName];
        return viewMappingInit();
    } else {
        [database asyncRegisterExtension:filteredView withName:viewName completionBlock:^(BOOL ready) {
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
    return [DLFYapDatabaseViewAndMapping viewMappingWithViewName:[DLFYapDatabaseViewAndMapping flattenedViewName:viewMappingSource.mapping.view] collection:viewMappingSource.collection database:database sortKey:viewMappingSource.sortKey sortKeyAsc:viewMappingSource.sortKeyAscending groupKey:nil groupSortAsc:NO isPersistent:viewMappingSource.isPersistent completion:completionBlock filterBlock:viewMappingSource.filterBlock];
}

+ (void)asyncViewMappingWithViewName:(NSString *)viewName
                          collection:(NSString *)collection
                            database:(YapDatabase *)database
                             sortKey:(NSString *)sortKey
                          sortKeyAsc:(BOOL)ascending
                          completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewName collection:collection database:database sortKey:sortKey sortKeyAsc:ascending groupKey:nil groupSortAsc:NO isPersistent:YES completion:completionBlock filterBlock:nil];
}

+ (void)asyncViewMappingWithViewName:(NSString *)viewName
                          collection:(NSString *)collection
                            database:(YapDatabase *)database
                             sortKey:(NSString *)sortKey
                          sortKeyAsc:(BOOL)sortKeyAsc
                            groupKey:(NSString *)groupKey
                        groupSortAsc:(BOOL)groupSortAsc
                          completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewName collection:collection database:database sortKey:sortKey sortKeyAsc:sortKeyAsc groupKey:groupKey groupSortAsc:groupSortAsc isPersistent:YES completion:completionBlock filterBlock:nil];
}

+ (void)asyncViewMappingWithViewName:(NSString *)viewName
                          collection:(NSString *)collection
                            database:(YapDatabase *)database
                             sortKey:(NSString *)sortKey
                          sortKeyAsc:(BOOL)ascending
                        isPersistent:(BOOL)isPersistent
                         filterBlock:(BOOL(^)(NSString *collection, NSString *key, id object))filterBlock
                          completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewName collection:collection database:database sortKey:sortKey sortKeyAsc:ascending groupKey:nil groupSortAsc:NO isPersistent:isPersistent completion:completionBlock filterBlock:filterBlock];
}

+ (void)asyncViewMappingWithViewName:(NSString *)viewName
                          collection:(NSString *)collection
                            database:(YapDatabase *)database
                             sortKey:(NSString *)sortKey
                          sortKeyAsc:(BOOL)sortKeyAsc
                            groupKey:(NSString *)groupKey
                        groupSortAsc:(BOOL)groupSortAsc
                        isPersistent:(BOOL)isPersistent
                         filterBlock:(BOOL(^)(NSString *collection, NSString *key, id object))filterBlock
                          completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:viewName collection:collection database:database sortKey:sortKey sortKeyAsc:sortKeyAsc groupKey:groupKey groupSortAsc:groupSortAsc isPersistent:isPersistent completion:completionBlock filterBlock:filterBlock];
}

+ (void)asyncUngroupedViewMappingFromViewMapping:(DLFYapDatabaseViewAndMapping *)viewMappingSource
                                        database:(YapDatabase *)database
                                      completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    [DLFYapDatabaseViewAndMapping ungroupedViewMappingFromViewMapping:viewMappingSource database:database completion:completionBlock];
}

+ (NSString *)flattenedViewName:(NSString *)viewName {
    return [NSString stringWithFormat:@"%@-flattened", viewName];
}

+ (NSString *)filteredViewNameFromParentViewName:(NSString *)parentViewName filterName:(NSString *)filterName{
    return [NSString stringWithFormat:@"%@-%@", filterName, parentViewName];
}

+ (void)asyncFilteredViewMappingFromViewName:(NSString *)fromViewName
                                    database:(YapDatabase *)database
                                  collection:(NSString *)collection
                                isPersistent:(BOOL)isPersistent
                   skipInitialViewPopulation:(BOOL)skipInitialViewPopulation
                                  filterName:(NSString *)filterName
                                groupSortAsc:(BOOL)groupSortAscending
                                 filterBlock:(BOOL (^)(NSString *, NSString *, id))filterBlock completion:(void(^)(DLFYapDatabaseViewAndMapping *viewMapping))completionBlock {
    [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:fromViewName database:database collection:collection isPersistent:isPersistent skipInitialViewPopulation:skipInitialViewPopulation groupSortAsc:groupSortAscending filterName:filterName filterBlock:filterBlock completion:completionBlock];
}

@end
