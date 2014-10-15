//
//  AlbumsDataSource.h
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "YapDataSource.h"

@class DLFYapDatabaseViewAndMapping;

@interface AlbumsDataSource : YapDataSource

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *updatedLastAlbumsViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *updatedFirstAlbumsViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *alphabetAscAlbumsViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *alphabetDescAlbumsViewMapping;

@end
