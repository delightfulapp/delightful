//
//  YapDatasourceWithSearching.h
//  Delightful
//
//  Created by  on 11/9/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "YapDataSource.h"

typedef BOOL(^searchFilterBlock)(NSString *collection, NSString *key, id object, NSString *searchText);

@interface YapDatasourceWithSearching : YapDataSource

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *unfilteredSelectedViewMapping;

- (void)filterWithSearchText:(NSString *)searchText;

- (searchFilterBlock)searchFilterBlock;

@end
