//
//  SyncEngine.m
//  Delightful
//
//  Created by  on 10/13/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "SyncEngine.h"

#import "PhotoBoxClient.h"

#import "DLFDatabaseManager.h"

#import "Photo.h"

#import "Album.h"

#import "Tag.h"

#import "GroupedPhotosDataSource.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import <YapDatabase.h>

#define FETCHING_PAGE_SIZE 20

#define DEFAULT_PHOTOS_SORT @"dateUploaded,desc"

#define ALL_PHOTOS_COLLECTION @"##!!_ALL_PHOTOS_COLLECTION_##!!"

NSString *const SyncEngineWillStartInitializingNotification = @"com.getdelightfulapp.SyncEngineWillStartInitializingNotification";
NSString *const SyncEngineDidFinishInitializingNotification = @"com.getdelightfulapp.SyncEngineDidFinishInitializingNotification";

NSString *const SyncEngineWillStartFetchingNotification = @"com.getdelightfulapp.SyncEngineWillStartFetchingNotification";
NSString *const SyncEngineDidFinishFetchingNotification = @"com.getdelightfulapp.SyncEngineDidFinishFetchingNotification";
NSString *const SyncEngineDidFailFetchingNotification = @"com.getdelightfulapp.SyncEngineDidFailFetchingNotification";

NSString *const SyncEngineNotificationResourceKey = @"resource";
NSString *const SyncEngineNotificationIdentifierKey = @"identifier";
NSString *const SyncEngineNotificationPageKey = @"page";
NSString *const SyncEngineNotificationErrorKey = @"error";
NSString *const SyncEngineNotificationCountKey = @"count";

NSString *const PhotosCollectionLastSyncKey = @"photos_collection_last_sync";

NSString *const PhotosLastSyncDateKey = @"photos_last_sync";
NSString *const PhotosCacheExpirationKey = @"photos_cache_expiration_interval";
NSString *const SyncSettingCollectionName = @"sync_setting_collection_name";

@interface SyncPhotosParam : NSObject

@property (nonatomic, assign) BOOL isSyncing;
@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, assign) int photosFetchingPage;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) BOOL refreshRequested;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic) Class collectionType;

@end

@implementation SyncPhotosParam
@end

@interface SyncEngine ()

@property (nonatomic, strong) YapDatabase *database;

@property (nonatomic, strong) YapDatabaseConnection *photosConnection;

@property (nonatomic, strong) YapDatabaseConnection *albumsConnection;

@property (nonatomic, strong) YapDatabaseConnection *tagsConnection;

@property (nonatomic, strong) YapDatabaseConnection *readConnection;

@property (nonatomic, assign) int albumsFetchingPage;

@property (nonatomic, assign) int photosFetchingPage;

@property (nonatomic, assign) BOOL tagsRefreshRequested;

@property (nonatomic, assign) BOOL albumsRefreshRequested;

@property (nonatomic, assign) BOOL photosRefreshRequested;

@property (nonatomic, assign) BOOL isSyncingPhotos;
@property (nonatomic, assign) BOOL isSyncingAlbums;
@property (nonatomic, assign) BOOL isSyncingTags;
@property (nonatomic, assign) BOOL isInitializing;

@property (nonatomic, strong) NSMutableDictionary *syncingJobs;

@property (nonatomic, strong) NSDate *lastSyncAlbums;
@property (nonatomic, strong) NSDate *lastSyncTags;

@property (nonatomic, strong) NSOperation *allPhotosFetchingOperation;

@end

@implementation SyncEngine

+ (instancetype)sharedEngine {
    static id _sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[self alloc] init];
    });
    
    return _sharedEngine;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.database = [[DLFDatabaseManager manager] currentDatabase];
        
        self.photosConnection = [self.database newConnection];
        self.photosConnection.objectCacheEnabled = NO; // don't need cache for write-only connection
        self.photosConnection.metadataCacheEnabled = NO;
        
        self.albumsConnection = [self.database newConnection];
        self.albumsConnection.objectCacheEnabled = NO; // don't need cache for write-only connection
        self.albumsConnection.metadataCacheEnabled = NO;
        
        self.tagsConnection = [self.database newConnection];
        self.tagsConnection.objectCacheEnabled = NO; // don't needpa cache for write-only connection
        self.tagsConnection.metadataCacheEnabled = NO;
        
        self.readConnection = [self.database newConnection];
        self.readConnection.objectCacheEnabled = YES; // don't needpa cache for write-only connection
        self.readConnection.metadataCacheEnabled = NO;
        
        self.syncingJobs = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)initialize {
    if (!self.isInitializing) {
        self.isInitializing = YES;
        CLS_LOG(@"Starting initialization");
        
        __block NSDate *lastPhotosSyncDate;
        __block int secondsPhotosCacheExpiration;
        [self.readConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            lastPhotosSyncDate = [transaction objectForKey:PhotosLastSyncDateKey inCollection:SyncSettingCollectionName];
            secondsPhotosCacheExpiration = [[transaction objectForKey:PhotosCacheExpirationKey inCollection:SyncSettingCollectionName] intValue];
        }];
        if (secondsPhotosCacheExpiration == 0) {
            secondsPhotosCacheExpiration = DEFAULT_PHOTOS_CACHE_AGE;
        }
        BOOL needToInvalidateCache = NO;
        if (lastPhotosSyncDate) {
            CLS_LOG(@"There is last photos sync date. Checking if it has expired");
            NSDate *date = [NSDate date];
            NSInteger interval = [date timeIntervalSinceDate:lastPhotosSyncDate];
            if (interval > secondsPhotosCacheExpiration) {
                needToInvalidateCache = YES;
            }
        } else {
            CLS_LOG(@"No last photos sync date.");
            needToInvalidateCache = YES;
        }
        
        [self.photosConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction setObject:[NSDate date] forKey:PhotosLastSyncDateKey inCollection:SyncSettingCollectionName];
        }];
        
        if (needToInvalidateCache) {
            CLS_LOG(@"Cache expired. Removing photos.");
            [[DLFDatabaseManager manager] removeAllPhotosWithCompletion:^{
                self.isInitializing = NO;
                [self startSyncingPhotos];
            }];
        } else {
            self.isInitializing = NO;
        }
    }
}

- (void)startSyncingPhotos {
    void (^fetchingPhotosBlock)() = ^void() {
        [self fetchPhotosForPage:0 sort:self.photosSyncSort?:DEFAULT_PHOTOS_SORT];
    };
    
    if (!self.isSyncingPhotos) {
        if (!self.isInitializing) {
            fetchingPhotosBlock();
        }
    }
}

- (void)startSyncingAlbums {
    if (!self.isSyncingAlbums && !self.isInitializing) {
        self.lastSyncAlbums = [NSDate date];
        [self fetchAlbumsForPage:1];
    }
}

- (void)startSyncingTags {
    if (!self.isSyncingTags && !self.isInitializing) {
        self.lastSyncTags = [NSDate date];
        [self fetchTagsForPage:1];
    }
}

- (void)initializeTags {
    self.lastSyncTags = [NSDate date];
    [self fetchTagsForPage:1];
}

- (void)initializeAlbums {
    self.lastSyncAlbums = [NSDate date];
    [self fetchAlbumsForPage:1];
}

- (void)startSyncingPhotosInCollection:(NSString *)collection collectionType:(Class)collectionType sort:(NSString *)sort {
    if (![self isSyncingPhotosInCollectionWithIdentifier:collection]) {
        if (collectionType == Album.class) {
            [self fetchPhotosInAlbum:collection page:0 sort:sort];
        } else if (collectionType == Tag.class) {
            [self fetchPhotosInTag:collection page:0 sort:sort];
        } else {
            [self fetchPhotosForPage:0 sort:sort];
        }
    }
}

- (void)refreshResource:(NSString *)resource {
    if ([resource isEqualToString:NSStringFromClass([Tag class])]) {
        self.tagsRefreshRequested = YES;
    } else if ([resource isEqualToString:NSStringFromClass([Album class])]) {
        self.albumsRefreshRequested = YES;
    }
}


- (void)fetchTagsForPage:(int)page {
    CLS_LOG(@"Fetching tags page %d", page);
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page)}];
    self.isSyncingTags = YES;
    
    [[PhotoBoxClient sharedClient] getTagsForPage:page pageSize:0 success:^(NSArray *tags) {
        CLS_LOG(@"Did finish fetching %d tags page %d", (int)tags.count, page);
        if (tags.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.tagsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    for (Tag *tag in tags) {
                        [transaction setObject:tag forKey:tag.tagId inCollection:tagsCollectionName withMetadata:@{PhotosCollectionLastSyncKey: self.lastSyncTags}];
                    }
                } completionBlock:^{
                    CLS_LOG(@"Done inserting tags to db");
                    
                    if (self.isInitializing) {
                        self.isInitializing = NO;
                        self.isSyncingPhotos = NO;
                        NSLog(@"Done initialization");
                        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishInitializingNotification object:nil];
                        [self startSyncingPhotos];
                    }
                    
                    [self.tagsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                        __block NSMutableArray *toDeleteTags = [NSMutableArray array];
                        [transaction enumerateKeysAndMetadataInCollection:tagsCollectionName usingBlock:^(NSString *key, NSDictionary *metadata, BOOL *stop) {
                            NSDate *lastSyncDate = metadata[PhotosCollectionLastSyncKey];
                            if (![lastSyncDate isEqualToDate:self.lastSyncTags]) {
                                [toDeleteTags addObject:key];
                            }
                        }];
                        if (toDeleteTags.count > 0) {
                            [transaction removeObjectsForKeys:toDeleteTags inCollection:tagsCollectionName];
                        }
                    } completionBlock:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationCountKey: @(tags.count)}];
                        self.isSyncingTags = NO;
                        
                        if (self.tagsRefreshRequested) {
                            self.tagsRefreshRequested = NO;
                            [self fetchTagsForPage:0];
                        }
                    }];
                }];
            });
        }
        
    } failure:^(NSError *error) {
        CLS_LOG(@"Error fetching tags page %d: %@", page, error);
        self.isSyncingTags = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page)}];
    }];
}

- (void)fetchAlbumsForPage:(int)page {
    CLS_LOG(@"Fetching albums page %d", page);
    self.isSyncingAlbums = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page)}];
    
    [[PhotoBoxClient sharedClient] getAlbumsForPage:page pageSize:FETCHING_PAGE_SIZE success:^(NSArray *albums) {
        CLS_LOG(@"Did finish fetching %d albums page %d", (int)albums.count, page);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationCountKey: @(albums.count)}];
        
        if (albums.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [self.albumsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    for (Album *album in albums) {
                        [transaction setObject:album forKey:album.albumId inCollection:albumsCollectionName withMetadata:@{PhotosCollectionLastSyncKey:self.lastSyncAlbums}];
                    }
                } completionBlock:^{
                    CLS_LOG(@"Done inserting albums to db page %d", page);
                    
                    if (self.albumsRefreshRequested) {
                        self.albumsRefreshRequested = NO;
                        [self fetchAlbumsForPage:1];
                    } else {
                        if (self.pauseAlbumsSync) {
                            self.albumsFetchingPage = page;
                        } else {
                            [self fetchAlbumsForPage:page+1];
                        }
                    }
                }];
            });
        } else {
            self.isSyncingAlbums = NO;
            self.albumsFetchingPage = 0;
            [self.albumsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                __block NSMutableArray *toDeleteKeys = [NSMutableArray array];
                [transaction enumerateKeysAndMetadataInCollection:albumsCollectionName usingBlock:^(NSString *key, NSDictionary *metadata, BOOL *stop) {
                    NSDate *lastSyncDate = metadata[PhotosCollectionLastSyncKey];
                    if (![lastSyncDate isEqualToDate:self.lastSyncAlbums]) {
                        [toDeleteKeys addObject:key];
                    }
                }];
                
                if (toDeleteKeys.count > 0) {
                    [transaction removeObjectsForKeys:toDeleteKeys inCollection:albumsCollectionName];
                }
            } completionBlock:^{
                if (self.isInitializing) {
                    [self initializeTags];
                }
            }];
        }
    } failure:^(NSError *error) {
        CLS_LOG(@"Error fetching albums page %d: %@", page, error);
        self.isSyncingAlbums = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page)}];
        self.albumsFetchingPage = page;
    }];
}

- (void)fetchPhotosForPage:(int)page sort:(NSString *)sort{
    CLS_LOG(@"Fetching photos for page %d", page);
    self.isSyncingPhotos = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page)}];
    
    [[PhotoBoxClient sharedClient] getPhotosForPage:page sort:sort pageSize:FETCHING_PAGE_SIZE success:^(NSArray *photos) {
        CLS_LOG(@"Did finish fetching %d photos page %d", (int)photos.count, page);
        
        [self didFetchPhotos:photos collection:nil collectionType:nil page:page sort:sort];
    } failure:^(NSError *error) {
        CLS_LOG(@"Error fetching photos page %d: %@", page, error);
        self.isSyncingPhotos = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page)}];
        self.photosFetchingPage = page;
    }];
}

- (void)fetchPhotosInTag:(NSString *)tag page:(int)page sort:(NSString *)sort {
    [self setIsSyncing:YES photosInCollection:tag collectionType:Tag.class page:page sort:sort];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationIdentifierKey:tag}];
    
    [[PhotoBoxClient sharedClient] getPhotosInTag:tag sort:sort page:page pageSize:FETCHING_PAGE_SIZE success:^(NSArray *photos) {
        CLS_LOG(@"Did finish fetching %d photos page %d in tag %@", (int)photos.count, page, tag);
        [self didFetchPhotos:photos collection:tag collectionType:[Tag class] page:page sort:sort];
    } failure:^(NSError *error) {
        [self setIsSyncing:NO photosInCollection:tag collectionType:Tag.class page:page sort:sort];
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationIdentifierKey:tag, SyncEngineNotificationPageKey: @(page)}];
    }];
}

- (void)fetchPhotosInAlbum:(NSString *)album page:(int)page sort:(NSString *)sort {
    NSLog(@"Fetching photos in album %@ page %d", album, page);
    [self setIsSyncing:YES photosInCollection:album collectionType:Album.class page:page sort:sort];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationIdentifierKey:album}];
    
    [[PhotoBoxClient sharedClient] getPhotosInAlbum:album sort:sort page:page pageSize:FETCHING_PAGE_SIZE success:^(NSArray *photos) {
        NSLog(@"Did finish fetching %d photos page %d in album %@", (int)photos.count, page, album);
        
        [self didFetchPhotos:photos collection:album collectionType:[Album class] page:page sort:sort];
    } failure:^(NSError *error) {
        [self setIsSyncing:NO photosInCollection:album collectionType:Album.class page:page sort:sort];
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationIdentifierKey:album, SyncEngineNotificationPageKey: @(page)}];
    }];
}

- (void)didFetchPhotos:(NSArray *)photos collection:(NSString *)collection collectionType:(Class)collectionType page:(int)page sort:(NSString *)sort{
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationCountKey: @(photos.count), SyncEngineNotificationIdentifierKey:collection?:[NSNull null]}];
    
    void (^refreshSyncing)() = ^void() {
        [self setRefreshRequested:NO collection:collection];
        [self pauseSyncingPhotos:NO collection:collection];
        [self setPhotosFetchingPage:0 photosInCollection:collection];
        if (collectionType == [Album class]) {
            [self fetchPhotosInAlbum:collection page:0 sort:sort];
        } else if (collectionType == [Tag class]) {
            [self fetchPhotosInTag:collection page:0 sort:sort];
        } else {
            [self fetchPhotosForPage:0 sort:sort];
        }
    };
    
    if ([self isRefreshRequestedForCollection:collection]) {
        NSLog(@"photos refresh in %@ requested", collection);
        refreshSyncing();
    } else {
        if ([self isPausedForCollection:collection]) {
            CLS_LOG(@"Pausing photos in %@ sync before inserting to db", collection);
            [self setIsPaused:NO collection:collection];
            if ([self isRefreshRequestedForCollection:collection]) {
                refreshSyncing();
            } else {
                [self setPhotosFetchingPage:page photosInCollection:collection];
                [self setIsSyncing:NO photosInCollection:collection collectionType:collectionType page:page sort:sort];
            }
        } else {
            if (photos.count > 0) {
                [self insertPhotos:photos completion:^{
                    CLS_LOG(@"Done inserting photos in %@ to db page %d", collection, page);
                    
                    if ([self isRefreshRequestedForCollection:collection]) {
                        refreshSyncing();
                    } else {
                        if ([self isPausedForCollection:collection]) {
                            CLS_LOG(@"Pausing photos sync in %@", collection);
                            [self setIsPaused:NO collection:collection];
                            [self setPhotosFetchingPage:page photosInCollection:collection];
                            [self setIsSyncing:NO photosInCollection:collection collectionType:collectionType page:page sort:sort];
                        } else {
                            if (collectionType == [Album class]) {
                                [self fetchPhotosInAlbum:collection page:page+1 sort:sort];
                            } else if (collectionType == [Tag class]) {
                                [self fetchPhotosInTag:collection page:page+1 sort:sort];
                            } else {
                                [self fetchPhotosForPage:page+1 sort:sort];
                            }
                        }
                    }
                }];
            } else {
                if ([self isRefreshRequestedForCollection:collection]) {
                    refreshSyncing();
                } else {
                    CLS_LOG(@"No photos fetched for page %d", page);
                    [self setPhotosFetchingPage:0 photosInCollection:collection];
                    [self setIsSyncing:NO photosInCollection:collection collectionType:collectionType page:page sort:sort];
                }
            }
        }
    }
}

- (void)setRefreshRequested:(BOOL)refreshRequested collection:(NSString *)collectionIdentifier {
    NSString *coll = collectionIdentifier?:ALL_PHOTOS_COLLECTION;
    
    SyncPhotosParam *param = [self.syncingJobs objectForKey:coll];
    if (!param) {
        param = [[SyncPhotosParam alloc] init];
        [param setIdentifier:coll];
    }
    [param setRefreshRequested:refreshRequested];
    [self.syncingJobs setObject:param forKey:coll];
}

- (BOOL)isRefreshRequestedForCollection:(NSString *)collectionIdentifier {
    NSString *coll = collectionIdentifier?:ALL_PHOTOS_COLLECTION;
    
    SyncPhotosParam *param = [self.syncingJobs objectForKey:coll];
    if (!param) {
        return NO;
    }
    return param.refreshRequested;
}

- (void)setIsPaused:(BOOL)pause collection:(NSString *)collectionIdentifier {
    NSString *coll = collectionIdentifier?:ALL_PHOTOS_COLLECTION;
    
    SyncPhotosParam *param = [self.syncingJobs objectForKey:coll];
    if (!param) {
        param = [[SyncPhotosParam alloc] init];
        [param setIdentifier:coll];
    }
    [param setIsPaused:pause];
    if (pause) NSLog(@"Pausing photos fetching in %@", coll);
    [self.syncingJobs setObject:param forKey:coll];
}

- (BOOL)isPausedForCollection:(NSString *)collectionIdentifier {
    NSString *coll = collectionIdentifier?:ALL_PHOTOS_COLLECTION;
    
    SyncPhotosParam *param = [self.syncingJobs objectForKey:coll];
    if (!param) {
        return NO;
    }
    return param.isPaused;
}

- (void)setIsSyncing:(BOOL)isSyncing photosInCollection:(NSString *)collectionIdentifier collectionType:(Class)collectionType page:(int)page sort:(NSString *)sort {
    NSString *coll = collectionIdentifier?:ALL_PHOTOS_COLLECTION;
    
    if (isSyncing) {
        SyncPhotosParam *param = [[SyncPhotosParam alloc] init];
        [param setIdentifier:collectionIdentifier];
        [param setIsSyncing:YES];
        [param setCollectionType:collectionType];
        [param setSort:sort];
        [param setPhotosFetchingPage:page];
        [self.syncingJobs setObject:param forKey:coll];
    } else {
        SyncPhotosParam *param = [self.syncingJobs objectForKey:coll];
        if (param) {
            [param setIsSyncing:NO];
            [param setPhotosFetchingPage:page];
            [self.syncingJobs setObject:param forKey:coll];
        }
    }
}

- (BOOL)isSyncingPhotosInCollectionWithIdentifier:(NSString *)collectionIdentifier {
    NSString *coll = collectionIdentifier?:ALL_PHOTOS_COLLECTION;
    
    SyncPhotosParam *param = [self.syncingJobs objectForKey:coll];
    if (!param) {
        return NO;
    }
    
    return param.isSyncing;
}

- (void)setPhotosFetchingPage:(int)photosFetchingPage photosInCollection:(NSString *)collectionIdentifier {
    NSString *coll = collectionIdentifier?:ALL_PHOTOS_COLLECTION;
    
    SyncPhotosParam *param = [self.syncingJobs objectForKey:coll];
    if (!param) {
        param = [[SyncPhotosParam alloc] init];
    }
    param.photosFetchingPage = photosFetchingPage;
    [self.syncingJobs setObject:param forKey:coll];
}

- (int)photosFetchingPageForIdentifier:(NSString *)collectionIdentifier {
    NSString *coll = collectionIdentifier?:ALL_PHOTOS_COLLECTION;
    
    SyncPhotosParam *param = [self.syncingJobs objectForKey:coll];
    if (!param) {
        return 0;
    }
    
    return param.photosFetchingPage;
}

- (void)pauseSyncingPhotos:(BOOL)pause collection:(NSString *)collection {
    NSString *coll = collection?:ALL_PHOTOS_COLLECTION;
    [self setIsPaused:pause collection:coll];
    
    if (!pause) {
        SyncPhotosParam *param = [self.syncingJobs objectForKey:coll];
        if (![self isSyncingPhotosInCollectionWithIdentifier:coll]) {
            if (param.collectionType == Album.class) {
                [self fetchPhotosInAlbum:param.identifier page:param.photosFetchingPage sort:param.sort];
            } else if (param.collectionType == Tag.class) {
                [self fetchPhotosInTag:param.identifier page:param.photosFetchingPage sort:param.sort];
            } else {
                [self fetchPhotosForPage:param.photosFetchingPage sort:param.sort];
            }
        }
        
    }
}

- (void)refreshPhotosInCollection:(NSString *)collection collectionType:(Class)collectionType sort:(NSString *)sort {
    NSString *coll = collection?:ALL_PHOTOS_COLLECTION;
    
    if (![self isSyncingPhotosInCollectionWithIdentifier:coll]) {
        if (collectionType == Album.class) {
            NSLog(@"Refresh album %@ requested", coll);
            [self fetchPhotosInAlbum:coll page:0 sort:sort];
        } else if (collectionType == Tag.class) {
            NSLog(@"Refresh photos in tag %@ requested", coll);
            [self fetchPhotosInTag:coll page:0 sort:sort];
        } else {
            NSLog(@"Refresh all photos");
            [self fetchPhotosForPage:0 sort:sort];
        }
    } else {
        [self setRefreshRequested:YES collection:coll];
    }
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    CLS_LOG(@"did receive memory warning");
}

- (void)insertPhotos:(NSArray *)photos completion:(void(^)())completionBlock {
    NSLog(@"inserting %d photos to db", (int)photos.count);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.photosConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for (Photo *photo in photos) {
                [transaction setObject:photo forKey:photo.photoId inCollection:photosCollectionName];
            }
        } completionBlock:completionBlock];
    });
    
}

@end
