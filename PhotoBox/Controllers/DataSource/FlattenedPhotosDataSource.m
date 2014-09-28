//
//  FlattenedPhotosDataSource.m
//  Delightful
//
//  Created by  on 9/29/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "FlattenedPhotosDataSource.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import "Photo.h"

NSString *dateUploadedLastFlatViewName = @"date-uploaded-last-photos-flat";

@implementation FlattenedPhotosDataSource

- (void)setupDatabase {
    [super setupDatabase];
    
    DLFYapDatabaseViewAndMapping *viewMapping = [DLFYapDatabaseViewAndMapping databaseViewAndMappingForKeyToCompare:NSStringFromSelector(@selector(dateUploadedString)) database:self.database viewName:dateUploadedLastFlatViewName asc:NO grouped:NO];
    
    [self setSelectedMappings:viewMapping.mapping];
}

@end
