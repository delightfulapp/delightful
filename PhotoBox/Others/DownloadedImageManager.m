//
//  DownloadedImageManager.m
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DownloadedImageManager.h"

#import "Photo.h"

#import "DLFDatabaseManager.h"

#import <YapDatabase.h>

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
    [photo setValue:currentDate forKey:NSStringFromSelector(@selector(downloadedDate))];
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:currentDate forKey:photo.photoId inCollection:[self photosCollectionName]];
    }];
    
}

- (BOOL)photoHasBeenDownloaded:(Photo *)photo {
    __block BOOL has;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        has = [transaction hasObjectForKey:photo.photoId inCollection:[self photosCollectionName]];
    }];
    return has;
}

- (void)clearHistory {
    NSString *collectionName = [self photosCollectionName];
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
                [transaction setObject:photo.downloadedDate forKey:photo.photoId inCollection:[self photosCollectionName]];
            }
        }];
    }
}

#pragma mark - Constants

- (NSString *)photosCollectionName {
    return downloadedPhotosCollectionName;
}

- (NSString *)downloadedImageKey {
    return kDownloadedImageManagerKey;
}

@end
