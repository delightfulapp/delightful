//
//  YapDatasourceWithSearching.m
//  Delightful
//
//  Created by  on 11/9/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "YapDatasourceWithSearching.h"

#import "DLFYapDatabaseViewAndMapping.h"

@implementation YapDatasourceWithSearching

- (void)filterWithSearchText:(NSString *)searchText {
    if (searchText && searchText.length > 0) {
        if (!self.unfilteredSelectedViewMapping) self.unfilteredSelectedViewMapping = self.selectedViewMapping;
        DLFYapDatabaseViewAndMapping *filteredMapping = [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:self.unfilteredSelectedViewMapping.viewName database:self.database collection:self.unfilteredSelectedViewMapping.collection isPersistent:NO skipInitialViewPopulation:NO filterName:[NSString stringWithFormat:@"%@-%@", self.unfilteredSelectedViewMapping.viewName, searchText] groupSortAsc:self.unfilteredSelectedViewMapping.groupSortAscending filterBlock:^BOOL(NSString *collection, NSString *key, id object) {
            searchFilterBlock block = [self searchFilterBlock];
            if (block) {
                return block(collection, key, object, searchText);
            }
            return NO;
        }];
        [self setSelectedViewMapping:filteredMapping];
    } else {
        if (self.unfilteredSelectedViewMapping) {
            [self setSelectedViewMapping:self.unfilteredSelectedViewMapping];
            self.unfilteredSelectedViewMapping = nil;
        }
    }
}

- (searchFilterBlock)searchFilterBlock {
    BOOL (^filter)(NSString *collection, NSString *key, id object, NSString *searchText) = ^BOOL(NSString *collection, NSString *key, id object, NSString *searchText) {
        return YES;
    };
    return filter;
}

@end
