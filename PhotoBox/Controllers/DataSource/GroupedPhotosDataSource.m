//
//  GroupedPhotosDataSource.m
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "GroupedPhotosDataSource.h"

#import "Photo.h"

NSString *dateUploadedLastViewName = @"date-uploaded-last-photos";
NSString *dateTakenLastViewName = @"date-taken-last-photos";
NSString *dateUploadedFirstViewName = @"date-uploaded-first-photos";
NSString *dateTakenFirstViewName = @"date-taken-first-photos";

@implementation GroupedPhotosDataSource

- (void)setupDatabase {
    [super setupDatabase];
    
    self.dateUploadedLastView = [self databaseViewForKeyToCompare:NSStringFromSelector(@selector(dateUploadedString)) name:dateUploadedLastViewName asc:NO];
    self.dateUploadedLastViewMappings = [self databaseViewMappingsWithViewName:dateUploadedLastViewName asc:NO];
    self.dateUploadedFirstView = [self databaseViewForKeyToCompare:NSStringFromSelector(@selector(dateUploadedString)) name:dateUploadedFirstViewName asc:YES];
    self.dateUploadedFirstViewMappings = [self databaseViewMappingsWithViewName:dateUploadedFirstViewName asc:YES];
    
    self.dateTakenFirstView = [self databaseViewForKeyToCompare:NSStringFromSelector(@selector(dateTakenString)) name:dateTakenFirstViewName asc:YES];
    self.dateTakenFirstViewMappings = [self databaseViewMappingsWithViewName:dateTakenFirstViewName asc:YES];
    self.dateTakenLastView = [self databaseViewForKeyToCompare:NSStringFromSelector(@selector(dateTakenString)) name:dateTakenLastViewName asc:NO];
    self.dateTakenLastViewMappings = [self databaseViewMappingsWithViewName:dateTakenLastViewName asc:NO];

    [self setSelectedMappings:self.dateTakenLastViewMappings];
}

- (YapDatabaseView *)databaseViewForKeyToCompare:(NSString *)keyToCompare name:(NSString *)viewName asc:(BOOL)ascending {
    YapDatabaseViewBlockType groupingBlockType = YapDatabaseViewBlockTypeWithObject;
    YapDatabaseViewGroupingWithObjectBlock groupingBlock = ^NSString *(NSString *collection, NSString *key, id object) {
        Photo *photo = (Photo *)object;
        return [[photo valueForKey:keyToCompare] description];
    };
    YapDatabaseViewBlockType sortingBlockType = YapDatabaseViewBlockTypeWithObject;
    YapDatabaseViewSortingWithObjectBlock sortingBlock = ^NSComparisonResult(NSString *group,
                                                                             NSString *collection1, NSString *key1, id obj1,
                                                                             NSString *collection2, NSString *key2, id obj2){
        return (ascending)?[[obj1 valueForKey:keyToCompare] compare:[obj2 valueForKey:keyToCompare]]:[[obj2 valueForKey:keyToCompare] compare:[obj1 valueForKey:keyToCompare]];
    };
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
                                                         groupingBlockType:groupingBlockType
                                                              sortingBlock:sortingBlock
                                                          sortingBlockType:sortingBlockType];
    [self.database registerExtension:view withName:viewName];
    return view;
}

- (YapDatabaseViewMappings *)databaseViewMappingsWithViewName:(NSString *)viewName asc:(BOOL)ascending {
    YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
        return YES;
    } sortBlock:^NSComparisonResult(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction) {
        return (ascending)?[group1 compare:group2]:[group2 compare:group1];
    } view:viewName];
    return mappings;
}

@end
