//
//  GroupedPhotosDataSource.m
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "GroupedPhotosDataSource.h"

#import "Photo.h"

#import "DLFYapDatabaseViewAndMapping.h"

NSString *dateUploadedLastViewName = @"date-uploaded-last-photos";
NSString *dateTakenLastViewName = @"date-taken-last-photos";
NSString *dateUploadedFirstViewName = @"date-uploaded-first-photos";
NSString *dateTakenFirstViewName = @"date-taken-first-photos";

@implementation GroupedPhotosDataSource

- (void)setupDatabase {
    [super setupDatabase];
    
    // last uploaded -> first uploaded view and mappings grouped
    DLFYapDatabaseViewAndMapping *viewMapping = [DLFYapDatabaseViewAndMapping databaseViewAndMappingForKeyToCompare:NSStringFromSelector(@selector(dateUploadedString)) database:self.database viewName:dateUploadedLastViewName asc:NO grouped:YES];
    self.dateUploadedLastView = viewMapping.view;
    self.dateUploadedLastViewMappings = viewMapping.mapping;
    
    viewMapping = [DLFYapDatabaseViewAndMapping databaseViewAndMappingForKeyToCompare:NSStringFromSelector(@selector(dateUploadedString)) database:self.database viewName:dateUploadedFirstViewName asc:YES grouped:YES];
    // first uploaded -> last uploaded view and mappings grouped
    self.dateUploadedFirstView = viewMapping.view;
    self.dateUploadedFirstViewMappings = viewMapping.mapping;
    
    // first taken -> last taken view and mappings grouped
    viewMapping = [DLFYapDatabaseViewAndMapping databaseViewAndMappingForKeyToCompare:NSStringFromSelector(@selector(dateTakenString)) database:self.database viewName:dateTakenFirstViewName asc:YES grouped:YES];
    self.dateTakenFirstView = viewMapping.view;
    self.dateTakenFirstViewMappings = viewMapping.mapping;
    
    // last taken -> first taken view and mappings grouped
    viewMapping = [DLFYapDatabaseViewAndMapping databaseViewAndMappingForKeyToCompare:NSStringFromSelector(@selector(dateTakenString)) database:self.database viewName:dateTakenLastViewName asc:NO grouped:YES];
    self.dateTakenLastView = viewMapping.view;
    self.dateTakenLastViewMappings = viewMapping.mapping;

    [self setSelectedMappings:self.dateTakenLastViewMappings];
}

@end
