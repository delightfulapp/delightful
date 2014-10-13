//
//  GroupedPhotosDataSource.h
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "YapDataSource.h"

@class DLFYapDatabaseViewAndMapping;

@interface GroupedPhotosDataSource : YapDataSource

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *dateUploadedLastViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *dateUploadedFirstViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *dateTakenLastViewMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *dateTakenFirstViewMapping;

@end
