//
//  DLFDatabase.m
//  Delightful
//
//  Created by  on 9/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "DLFDatabaseManager.h"
#import "GroupedPhotosDataSource.h"
#import "AlbumsDataSource.h"
#import "TagsDataSource.h"
#import "DLFYapDatabaseViewAndMapping.h"
#import "Photo.h"
#import "Album.h"
#import "Tag.h"
#import "DownloadedImageManager.h"
#import "FavoritesManager.h"
#import "YapDatabase.h"

NSString *photosCollectionName = @"photos";
NSString *albumsCollectionName = @"albums";
NSString *tagsCollectionName = @"tags";
NSString *createdViewsCollectionName = @"createdViews";
NSString *downloadedPhotosCollectionName = @"downloadedPhotos";
NSString *favoritedPhotosCollectionName = @"favoritedPhotos";
NSString *locationsCollectionName = @"locations";
NSString *uploadedCollectionName = @"uploaded";
NSString *photoUploadedKey = @"uploaded";
NSString *photoQueuedKey = @"queued";
NSString *photoUploadedFailedKey = @"failed";

@interface DLFDatabaseManager ()

@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *writeConnection;
@property (nonatomic, strong) YapDatabaseConnection *readConnection;


@end

@implementation DLFDatabaseManager

+ (instancetype)manager {
    static DLFDatabaseManager *_currentDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentDatabase = [[DLFDatabaseManager alloc] init];
        [_currentDatabase setupConnections];
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

- (void)setupConnections {
    self.writeConnection = [self.database newConnection];
    self.readConnection = [self.database newConnection];
    
    self.readConnection.objectCacheLimit = 500; // increase object cache size
    self.readConnection.metadataCacheEnabled = NO; // not using metadata on this connection
    
    self.writeConnection.objectCacheEnabled = NO; // don't need cache for write-only connection
    self.writeConnection.metadataCacheEnabled = NO;
}


- (NSString *)databasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    NSString *databaseName = @"database.sqlite";
    
    return [baseDir stringByAppendingPathComponent:databaseName];
}

- (int)numberOfPhotos {
    __block int count;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        count = (int)[transaction numberOfKeysInCollection:photosCollectionName];
    }];
    return count;
}

- (void)removeAlbumsCompletion:(void (^)())completion {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInCollection:albumsCollectionName];
    } completionBlock:completion];
}

- (void)removeTagsCompletion:(void (^)())completion {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInCollection:tagsCollectionName];
    } completionBlock:completion];
}

- (void)removeCollection:(Class)classCollection completion:(void (^)())completion {
    if (classCollection == Album.class) {
        [self removeAlbumsCompletion:completion];
    } else if (classCollection == Tag.class) {
        [self removeTagsCompletion:completion];
    }
}

- (void)removeAllItems {
    CLS_LOG(@"Removing all items");
    [self.writeConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInAllCollections];
    }];
}

- (void)removeAllPhotosWithCompletion:(void (^)())completion {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInCollection:photosCollectionName];
    } completionBlock:completion];
}

- (void)removeItemWithKey:(NSString *)key inCollection:(NSString *)collection {
    if (key && collection) {
        [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction removeObjectForKey:key inCollection:collection];
        }];
    }
}

- (void)removePhotosInFlattenedView:(NSString *)view completion:(void (^)())completion {
    __block NSMutableArray *keys = [NSMutableArray array];
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [[transaction ext:view] enumerateKeysInGroup:@"" usingBlock:^(NSString *collection, NSString *key, NSUInteger index, BOOL *stop) {
            if ([collection  isEqualToString:photosCollectionName]) {
                [keys addObject:key];
            }
        }];
        
        if (keys && keys.count > 0) {
            [transaction removeObjectsForKeys:keys inCollection:photosCollectionName];
        }
    } completionBlock:completion];
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
    
    [DownloadedImageManager databaseViewMappingWithDatabase:self.database collectionName:[DownloadedImageManager photosCollectionName] connection:self.readConnection viewName:[DownloadedImageManager databaseViewName]];
    [DownloadedImageManager databaseViewMappingWithDatabase:self.database collectionName:[DownloadedImageManager photosCollectionName] connection:self.readConnection viewName:[DownloadedImageManager flattenedDatabaseViewName]];
    [FavoritesManager databaseViewMappingWithDatabase:self.database collectionName:[FavoritesManager photosCollectionName] connection:self.readConnection viewName:[FavoritesManager databaseViewName]];
    [FavoritesManager databaseViewMappingWithDatabase:self.database collectionName:[FavoritesManager photosCollectionName] connection:self.readConnection viewName:[FavoritesManager flattenedDatabaseViewName]];
    
    __block NSMutableSet *createdViews = [NSMutableSet set];
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
       [transaction enumerateKeysAndObjectsInCollection:createdViewsCollectionName usingBlock:^(NSString *key, id object, BOOL *stop) {
           [createdViews addObject:object];
       }];
    }];
    
    for (NSDictionary *dict in createdViews) {
        NSString *filterName = dict[@"filterName"];
        BOOL groupSortAsc = [dict[@"groupSortAsc"] boolValue];
        NSString *objectKey = dict[@"objectKey"];
        NSString *filterKey = dict[@"filterKey"];
        NSString *fromViewName = dict[@"fromViewName"];
        [DLFYapDatabaseViewAndMapping filteredViewMappingFromViewName:fromViewName database:self.database collection:photosCollectionName isPersistent:YES skipInitialViewPopulation:YES filterName:filterName groupSortAsc:groupSortAsc  filterBlock:^BOOL(NSString *aCollection, NSString *key, Photo *object) {
            return [[object valueForKey:objectKey] containsObject:filterKey];
        }];
    }
}

- (void)saveFilteredViewName:(NSString *)viewName fromViewName:(NSString *)fromViewName filterName:(NSString *)filterName groupSortAsc:(BOOL)groupSortAsc objectKey:(NSString *)objectKey filterKey:(NSString *)filterKey {
    NSDictionary *dict = @{@"viewName": viewName, @"fromViewName": fromViewName, @"filterName": filterName, @"groupSortAsc": @(groupSortAsc), @"objectKey": objectKey, @"filterKey": filterKey};
    [self.writeConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:dict forKey:viewName inCollection:createdViewsCollectionName];
    }];
}

- (void)tagsWithCompletion:(void (^)(NSArray *))completion {
    [self.readConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSArray *tags = [transaction allKeysInCollection:tagsCollectionName];
        if (completion) {
            completion(tags);
        }
    }];
}

- (NSArray *)tags {
    __block NSArray *tags;
    
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        tags = [transaction allKeysInCollection:tagsCollectionName];
    }];
    
    return tags;
}

@end
