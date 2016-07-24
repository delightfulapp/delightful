//
//  DownloadedImageManager.m
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "DownloadedImageManager.h"

#import "Photo.h"

#import "DLFDatabaseManager.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import "YapDatabase.h"

#define kDownloadedImageManagerKey @"com.delightful.kDownloadedImageManagerKey"

@interface DownloadedImageManager ()

@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *readConnection;
@property (nonatomic, strong) YapDatabaseConnection *writeConnection;

@end

@implementation DownloadedImageManager

+ (instancetype)sharedManager {
    static DownloadedImageManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[DownloadedImageManager alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.database = [[DLFDatabaseManager manager] currentDatabase];
        self.writeConnection = [self.database newConnection];
        self.readConnection = [self.database newConnection];
        
        self.readConnection.objectCacheLimit = 500; // increase object cache size
        self.readConnection.metadataCacheEnabled = NO; // not using metadata on this connection
        
        self.writeConnection.objectCacheEnabled = NO; // don't need cache for write-only connection
        self.writeConnection.metadataCacheEnabled = NO;
        
        [self migrateFromUserDefaultsToDb];
    }
    return self;
}

- (void)addPhoto:(Photo *)photo {
    NSDate *currentDate = [NSDate date];
    NSString *downloadedOrFavoritedCollection = [self.class photosCollectionName];
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:currentDate forKey:photo.photoId inCollection:downloadedOrFavoritedCollection];
    } completionBlock:^{
        [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction setObject:photo forKey:photo.photoId inCollection:photosCollectionName];
        }];
    }];
    
}

- (BOOL)photoHasBeenDownloaded:(Photo *)photo {
    __block BOOL has;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        has = [transaction hasObjectForKey:photo.photoId inCollection:[self.class photosCollectionName]];
    }];
    return has;
}

- (void)clearHistory {
    NSString *collectionName = [self.class photosCollectionName];
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInCollection:collectionName];
    }];
}

- (void)migrateFromUserDefaultsToDb {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self downloadedImageKey]];
    NSMutableOrderedSet *previouslyDownloadedPhotos = [NSMutableOrderedSet orderedSet];
    if (data) {
        NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (arr) {
            [previouslyDownloadedPhotos addObjectsFromArray:arr];
        }
    }
    if (previouslyDownloadedPhotos.count > 0) {
        [self.writeConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for (Photo *photo in previouslyDownloadedPhotos) {
                [transaction setObject:photo.downloadedDate forKey:photo.photoId inCollection:[self.class photosCollectionName]];
            }
        }];
    }
}

- (DLFYapDatabaseViewAndMapping *)databaseViewMapping {
    return [self.class databaseViewMappingWithDatabase:self.database collectionName:[self.class photosCollectionName] connection:self.readConnection viewName:[self.class databaseViewName]];
}

- (DLFYapDatabaseViewAndMapping *)flattenedDatabaseViewMapping {
    return [self.class databaseViewMappingWithDatabase:self.database collectionName:[self.class photosCollectionName] connection:self.readConnection viewName:[self.class flattenedDatabaseViewName]];
}

+ (DLFYapDatabaseViewAndMapping *)databaseViewMappingWithDatabase:(id)database collectionName:(NSString *)collectionName connection:(YapDatabaseConnection *)connection viewName:(NSString *)viewName {
    YapDatabaseViewGrouping *grouping = [YapDatabaseViewGrouping withKeyBlock:^NSString *(NSString *collection, NSString *key) {
        if (![collection isEqualToString:photosCollectionName]) {
            return nil;
        }
        __block BOOL include = NO;
        [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            if ([transaction hasObjectForKey:key inCollection:collectionName]) {
                include = YES;
            }
        }];
        return (include)?@"":nil;
    }];
    
    YapDatabaseViewSorting *sorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, Photo *object1, NSString *collection2, NSString *key2, Photo *object2) {
        __block NSDate *date1, *date2;
        [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            date1 = [transaction objectForKey:key1 inCollection:collectionName];
            date2 = [transaction objectForKey:key2 inCollection:collectionName];
        }];
        return [date2 compare:date1];
    }];
    
    YapDatabaseViewOptions *option = [[YapDatabaseViewOptions alloc] init];
    [option setIsPersistent:YES];
    [option setSkipInitialViewPopulation:YES];
    [option setAllowedCollections:[[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:photosCollectionName]]];
    
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGrouping:grouping sorting:sorting versionTag:@"1.0" options:option];
    
    DLFYapDatabaseViewAndMapping *(^viewMappingInit)() = ^DLFYapDatabaseViewAndMapping *() {
        YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
            return (group)?YES:NO;
        } sortBlock:^NSComparisonResult(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction) {
            return [group1 compare:group2];
        } view:viewName];
        
        DLFYapDatabaseViewAndMapping *returnObject = [[DLFYapDatabaseViewAndMapping alloc] init];
        returnObject.view = view;
        returnObject.mapping = mappings;
        returnObject.viewName = viewName;
        returnObject.isPersistent = YES;
        returnObject.collection = photosCollectionName;
        
        return returnObject;
    };
    
    if (![database registeredExtension:viewName]) {
        
        [database registerExtension:view withName:viewName];
    }
    
    return viewMappingInit();
}

+ (NSString *)databaseViewName {
    return @"downloaded-photos";
}

+ (NSString *)flattenedDatabaseViewName {
    return @"downloaded-photos-flattened";
}

#pragma mark - Constants

+ (NSString *)photosCollectionName {
    return downloadedPhotosCollectionName;
}

- (NSString *)downloadedImageKey {
    return kDownloadedImageManagerKey;
}

@end
