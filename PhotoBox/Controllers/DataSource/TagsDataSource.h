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

@end
