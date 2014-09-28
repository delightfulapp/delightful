//
//  GroupedPhotosDataSource.h
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "YapDataSource.h"

@interface GroupedPhotosDataSource : YapDataSource

@property (nonatomic, strong) YapDatabaseView *dateUploadedLastView;
@property (nonatomic, strong) YapDatabaseViewMappings *dateUploadedLastViewMappings;
@property (nonatomic, strong) YapDatabaseView *dateUploadedFirstView;
@property (nonatomic, strong) YapDatabaseViewMappings *dateUploadedFirstViewMappings;
@property (nonatomic, strong) YapDatabaseView *dateTakenLastView;
@property (nonatomic, strong) YapDatabaseViewMappings *dateTakenLastViewMappings;
@property (nonatomic, strong) YapDatabaseView *dateTakenFirstView;
@property (nonatomic, strong) YapDatabaseViewMappings *dateTakenFirstViewMappings;

@end
