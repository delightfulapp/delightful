//
//  DLFDatabase.m
//  Delightful
//
//  Created by  on 9/23/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DLFDatabaseManager.h"

#import "GroupedPhotosDataSource.h"

#import "AlbumsDataSource.h"

#import "TagsDataSource.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import "Photo.h"

#import "Album.h"

#import "Tag.h"

#import <YapDatabase.h>

NSString *photosCollectionName = @"photos";
NSString *albumsCollectionName = @"albums";
NSString *tagsCollectionName = @"tags";

@interface DLFDatabaseManager ()

@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *connection;

@end

@implementation DLFDatabaseManager

+ (instancetype)manager {
    static DLFDatabaseManager *_currentDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentDatabase = [[DLFDatabaseManager alloc] init];
        [_currentDatabase setupViewExtensions];
    });
    
    return _currentDatabase;
}

- (YapDatabase *)currentDatabase {
    return self.database;
}

- (YapDatabase *)database {
    if (!_database) {
        _database = [[YapDatabase alloc] initWithPath:[self databasePath]];
    }
    return _database;
}

- (YapDatabaseConnection *)connection {
    if (!_connection) {
        _connection = [self.database newConnection];
    }
    return _connection;
}

- (NSString *)databasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    NSString *databaseName = @"database.sqlite";
    
    return [baseDir stringByAppendingPathComponent:databaseName];
}

- (void)removeAllItems {
    CLS_LOG(@"Removing all items");
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInAllCollections];
    }];
}

+ (void)removeDatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    NSString *databaseName = @"database.sqlite";
    
    NSString *path = [baseDir stringByAppendingPathComponent:databaseName];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

- (void)setupViewExtensions {
    DLFYapDatabaseViewAndMapping *dateUploadedLastViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateUploadedLastViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateUploaded)) sortKeyAsc:NO groupKey:NSStringFromSelector(@selector(dateUploadedString)) groupSortAsc:NO];
    
    // first uploaded -> last uploaded view and mappings grouped
    DLFYapDatabaseViewAndMapping *dateUploadedFirstViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateUploadedFirstViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateUploaded)) sortKeyAsc:YES groupKey:NSStringFromSelector(@selector(dateUploadedString)) groupSortAsc:YES];
    
    // first taken -> last taken view and mappings grouped
    DLFYapDatabaseViewAndMapping *dateTakenFirstViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateTakenFirstViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateTaken)) sortKeyAsc:YES groupKey:NSStringFromSelector(@selector(dateTakenString)) groupSortAsc:YES];
    
    // last taken -> first taken view and mappings grouped
    DLFYapDatabaseViewAndMapping *dateTakenLastViewMapping = [DLFYapDatabaseViewAndMapping viewMappingWithViewName:dateTakenLastViewName collection:photosCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateTaken)) sortKeyAsc:NO groupKey:NSStringFromSelector(@selector(dateTakenString)) groupSortAsc:NO];
    
    [DLFYapDatabaseViewAndMapping ungroupedViewMappingFromViewMapping:dateUploadedLastViewMapping database:self.database];
    [DLFYapDatabaseViewAndMapping ungroupedViewMappingFromViewMapping:dateUploadedFirstViewMapping database:self.database];
    [DLFYapDatabaseViewAndMapping ungroupedViewMappingFromViewMapping:dateTakenFirstViewMapping database:self.database];
    [DLFYapDatabaseViewAndMapping ungroupedViewMappingFromViewMapping:dateTakenLastViewMapping database:self.database];
    
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsUpdatedLastViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateLastPhotoAdded)) sortKeyAsc:NO];
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsUpdatedFirstViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(dateLastPhotoAdded)) sortKeyAsc:YES];
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsAlphabeticalAscendingViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(name)) sortKeyAsc:YES];
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:albumsAlphabeticalDescendingViewName collection:albumsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(name)) sortKeyAsc:NO];
    
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:tagsAlphabeticalFirstViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(tagId)) sortKeyAsc:YES];
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:tagsAlphabeticalLastViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(tagId)) sortKeyAsc:NO];
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:numbersFirstViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(count)) sortKeyAsc:YES];
    [DLFYapDatabaseViewAndMapping viewMappingWithViewName:numbersLastViewName collection:tagsCollectionName database:self.database sortKey:NSStringFromSelector(@selector(count)) sortKeyAsc:NO];
}

@end
