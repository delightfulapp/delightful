//
//  TagsDataSource.h
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "YapDataSource.h"

@class DLFYapDatabaseViewAndMapping;

@interface TagsDataSource : YapDataSource

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *alphabeticalFirstTagsViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *alphabeticalLastTagsViewMapping;

- (void)setSortByNameAscending:(BOOL)ascending;

@end
