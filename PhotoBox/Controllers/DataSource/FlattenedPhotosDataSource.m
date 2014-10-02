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

NSString *dateTakenLastFlatViewName = @"date-taken-last-photos-flat";

@implementation FlattenedPhotosDataSource

- (void)setupDatabase {
    [super setupDatabase];
    
    DLFYapDatabaseViewAndMapping *viewMapping = [DLFYapDatabaseViewAndMapping databaseViewAndMappingForKeyToCompare:NSStringFromSelector(@selector(dateTakenString)) database:self.database viewName:dateTakenLastFlatViewName asc:NO grouped:YES];
    
    [self setSelectedMappings:viewMapping.mapping];
}

@end
