//
//  SyncEngine.m
//  Delightful
//
//  Created by  on 10/13/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "SyncEngine.h"
#import "APIClient.h"
#import "DLFDatabaseManager.h"
#import "Photo.h"
#import "Album.h"
#import "Tag.h"
#import "GroupedPhotosDataSource.h"
#import "DLFYapDatabaseViewAndMapping.h"
#import "ConnectionManager.h"
#import "YapDatabase.h"

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

typedef NS_ENUM(NSInteger, SyncOperationType) {
    SyncOperationTypeNone,
    SyncOperationTypeAllPhotos,
    SyncOperationTypeTagPhotos,
    SyncOperationTypeAlbumPhotos,
    SyncOperationTypeAlbums,
    SyncOperationTypeTags
};

static NSString *const kLockName = @"com.getdelightfulapp.SyncingLock";

static void * kUserLoggedInContext = &kUserLoggedInContext;

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
@property (nonatomic, strong) NSURLSessionDataTask *allPhotosSyncingOperation;
@property (nonatomic, strong) NSURLSessionDataTask *photosInAlbumSyncingOperation;
@property (nonatomic, strong) NSURLSessionDataTask *photosInTagSyncingOperation;
@property (nonatomic, strong) NSURLSessionDataTask *tagsSyncingOperation;
@property (nonatomic, strong) NSURLSessionDataTask *albumsSyncingOperation;
@property (nonatomic, assign) BOOL pauseAllPhotosSyncOperation;
@property (nonatomic, assign) BOOL pausePhotosInAlbumSyncOperation;
@property (nonatomic, assign) BOOL pausePhotosInTagSyncOperation;
@property (nonatomic, assign) BOOL pauseAlbumsSyncOperation;
@property (nonatomic, assign) int allPhotosSyncOperationPage;
@property (nonatomic, assign) int photosInAlbumSyncOperationPage;
@property (nonatomic, assign) int photosInTagSyncOperationPage;
@property (nonatomic, assign) int albumsSyncOperationPage;
@property (nonatomic, strong) NSString *allPhotosSyncOperationSort;
@property (nonatomic, strong) NSString *photosInAlbumSyncOperationSort;
@property (nonatomic, strong) NSString *photosInTagSyncOperationSort;
@property (nonatomic, strong) NSString *photosInAlbumSyncOperationCollection;
@property (nonatomic, strong) NSString *photosInTagSyncOperationCollection;
@property (nonatomic, assign) SyncOperationType syncOperationType;

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
        self.tagsConnection.objectCacheEnabled = NO; // don't need cache for write-only connection
        self.tagsConnection.metadataCacheEnabled = NO;
        
        self.readConnection = [self.database newConnection];
        self.readConnection.objectCacheEnabled = YES; // don't need cache for write-only connection
        self.readConnection.metadataCacheEnabled = NO;
        
        [[ConnectionManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(isUserLoggedIn)) options:0 context:kUserLoggedInContext];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)startSyncingPhotosInCollection:(NSString *)collection collectionType:(Class)collectionType sort:(NSString *)sort {
    if (collectionType == Album.class) {
        if (self.photosInAlbumSyncingOperation) {
            [self.photosInAlbumSyncingOperation cancel];
        }
        self.pausePhotosInAlbumSyncOperation = NO;
        self.photosInAlbumSyncOperationSort = sort;
        self.photosInAlbumSyncOperationPage = 0;
        self.photosInAlbumSyncingOperation = [self fetchPhotosInAlbum:collection page:0 sort:sort];
    } else if (collectionType == Tag.class) {
        if (self.photosInTagSyncingOperation) {
            [self.photosInTagSyncingOperation cancel];
        }
        self.pausePhotosInTagSyncOperation = NO;
        self.photosInTagSyncOperationSort = sort;
        self.photosInTagSyncOperationPage = 1;
        self.photosInTagSyncingOperation = [self fetchPhotosInTag:collection page:1 sort:sort];
    } else {
        if (self.allPhotosSyncingOperation) {
            [self.allPhotosSyncingOperation cancel];
        }
        self.pauseAllPhotosSyncOperation = NO;
        self.allPhotosSyncOperationPage = 0;
        self.allPhotosSyncOperationSort = sort;
        self.allPhotosSyncingOperation = [self fetchPhotosForPage:0 sort:sort];
    }
}

- (void)startSyncingAlbums {
    if (self.albumsSyncingOperation) {
        [self.albumsSyncingOperation cancel];
    }
    self.albumsSyncingOperation = [self fetchAlbumsForPage:1];
}

- (void)startSyncingTags {
    if (self.tagsSyncingOperation) {
        [self.tagsSyncingOperation cancel];
    }
    self.tagsSyncingOperation = [self fetchTagsForPage:1];
}

- (void)refreshResource:(NSString *)resource {
    if ([resource isEqualToString:NSStringFromClass(Album.class)]) {
        self.pauseAlbumsSyncOperation = NO;
        [self.albumsSyncingOperation cancel];
        self.albumsSyncingOperation = [self fetchAlbumsForPage:1];
    } else if ([resource isEqualToString:NSStringFromClass(Tag.class)]) {
        [self.tagsSyncingOperation cancel];
        self.tagsSyncingOperation = [self fetchTagsForPage:1];
    }
}


- (NSURLSessionDataTask *)fetchTagsForPage:(int)page {
    //CLS_LOG(@"Fetching tags page %d", page);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page)}];
    });
    
    return [[APIClient sharedClient] getTagsForPage:page pageSize:0 success:^(NSArray *tags) {
        //CLS_LOG(@"Did finish fetching %d tags page %d", (int)tags.count, page);
        if (tags.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.tagsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    for (Tag *tag in tags) {
                        [transaction setObject:tag forKey:tag.tagId inCollection:tagsCollectionName];
                    }
                } completionBlock:^{
                }];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationCountKey: @(0)}];
        });
        
    } failure:^(NSError *error) {
        //CLS_LOG(@"Error fetching tags page %d: %@", page, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page)}];
    }];
}

- (NSURLSessionDataTask *)fetchAlbumsForPage:(int)page {
    CLS_LOG(@"Fetching albums page %d", page);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page)}];
    });
    
    self.albumsSyncOperationPage = page;
    
    return [[APIClient sharedClient] getAlbumsForPage:page pageSize:FETCHING_PAGE_SIZE success:^(NSArray *albums) {
        CLS_LOG(@"Did finish fetching %d albums page %d", (int)albums.count, page);
        
        if (albums.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [self.albumsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    for (Album *album in albums) {
                        [transaction setObject:album forKey:album.albumId inCollection:albumsCollectionName];
                    }
                } completionBlock:^{
                    //CLS_LOG(@"Done inserting albums to db page %d", page);
                    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationCountKey: @(albums.count)}];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!self.pauseAlbumsSyncOperation) {
                            if (self.albumsSyncingOperation.state != NSURLSessionTaskStateRunning ) {
                                self.albumsSyncingOperation = [self fetchAlbumsForPage:page+1];
                            }
                        }
                    });
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationCountKey: @(albums.count)}];
            });
        }
    } failure:^(NSError *error) {
        //CLS_LOG(@"Error fetching albums page %d: %@", page, error);
        dispatch_async(dispatch_get_main_queue(), ^{
           [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page)}];
        });
    }];
}

- (NSURLSessionDataTask *)fetchPhotosForPage:(int)page sort:(NSString *)sort{
    //CLS_LOG(@"Fetching photos for page %d", page);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page)}];
    });
    
    self.allPhotosSyncOperationPage = page;
    self.allPhotosSyncOperationSort = sort;
    
    return [[APIClient sharedClient] getPhotosForPage:page sort:sort pageSize:FETCHING_PAGE_SIZE success:^(NSArray *photos) {
        //CLS_LOG(@"Did finish fetching %d photos page %d", (int)photos.count, page);
        
        [self didFetchPhotos:photos collection:nil collectionType:nil page:page sort:sort];
    } failure:^(NSError *error) {
        //CLS_LOG(@"Error fetching photos page %d: %@", page, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page)}];
    }];
}

- (NSURLSessionDataTask *)fetchPhotosInTag:(NSString *)tag page:(int)page sort:(NSString *)sort {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationIdentifierKey:tag}];
    });
    
    self.photosInTagSyncOperationPage = page;
    self.photosInTagSyncOperationSort = sort;
    self.photosInTagSyncOperationCollection = tag;
    
    return [[APIClient sharedClient] getPhotosInTag:tag sort:sort page:page pageSize:FETCHING_PAGE_SIZE success:^(NSArray *photos) {
        //CLS_LOG(@"Did finish fetching %d photos page %d in tag %@", (int)photos.count, page, tag);
        [self didFetchPhotos:photos collection:tag collectionType:[Tag class] page:page sort:sort];
    } failure:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationIdentifierKey:tag, SyncEngineNotificationPageKey: @(page)}];
    }];
}

- (NSURLSessionDataTask *)fetchPhotosInAlbum:(NSString *)album page:(int)page sort:(NSString *)sort {
    //
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationIdentifierKey:album}];
    });
    
    self.photosInAlbumSyncOperationPage = page;
    self.photosInAlbumSyncOperationSort = sort;
    self.photosInAlbumSyncOperationCollection = album;
    
    return [[APIClient sharedClient] getPhotosInAlbum:album sort:sort page:page pageSize:FETCHING_PAGE_SIZE success:^(NSArray *photos) {
        // Bug fix: This is to fix the bug in Trovebox where albums array is empty https://github.com/photo/frontend/issues/1563
        NSMutableArray *mutablePhotos = [photos mutableCopy];
        if (album) {
            for (Photo *photo in mutablePhotos) {
                NSArray *albums = photo.albums;
                NSMutableArray *mutableAlbums;;
                if (albums) {
                    mutableAlbums = [albums mutableCopy];
                } else {
                    mutableAlbums = [NSMutableArray array];
                }
                [mutableAlbums addObject:album];
                
                [photo setValue:[NSArray arrayWithArray:mutableAlbums] forKey:NSStringFromSelector(@selector(albums))];
            }
        }
        // end of the bug fix
        [self didFetchPhotos:[NSArray arrayWithArray:mutablePhotos] collection:album collectionType:[Album class] page:page sort:sort];
    } failure:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationIdentifierKey:album, SyncEngineNotificationPageKey: @(page)}];
    }];
}

- (void)didFetchPhotos:(NSArray *)photos collection:(NSString *)collection collectionType:(Class)collectionType page:(int)page sort:(NSString *)sort{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationCountKey: @(photos.count), SyncEngineNotificationIdentifierKey:collection?:[NSNull null]}];
    });
    
    if (photos.count > 0) {
        [self insertPhotos:photos completion:^{
            //CLS_LOG(@"Done inserting photos in %@ to db page %d", collection, page);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (collectionType==Album.class) {
                    if (!self.pausePhotosInAlbumSyncOperation) {
                        if (self.photosInAlbumSyncingOperation.state != NSURLSessionTaskStateRunning) {
                            self.photosInAlbumSyncingOperation = [self fetchPhotosInAlbum:collection page:page+1 sort:sort];
                        }
                    }
                } else if (collectionType==Tag.class) {
                    if (!self.pausePhotosInTagSyncOperation) {
                        if (self.photosInTagSyncingOperation.state != NSURLSessionTaskStateRunning) {
                            self.photosInTagSyncingOperation = [self fetchPhotosInTag:collection page:page+1 sort:sort];
                        }
                    }
                } else {
                    if (!self.pauseAllPhotosSyncOperation) {
                        if (self.allPhotosSyncingOperation.state != NSURLSessionTaskStateRunning) {
                            self.allPhotosSyncingOperation = [self fetchPhotosForPage:page+1 sort:sort];
                        }
                    }
                }
            });
        }];
    }
}

- (void)pauseSyncingPhotos:(BOOL)pause collection:(NSString *)collection collectionType:(Class)collectionType {
    //
    if (collectionType==Album.class) {
        if (pause) {
            self.pausePhotosInAlbumSyncOperation = YES;
            [self.photosInAlbumSyncingOperation cancel];
        }
        else {
            if (self.pausePhotosInAlbumSyncOperation) {
                self.pausePhotosInAlbumSyncOperation = NO;
                self.photosInAlbumSyncingOperation = [self fetchPhotosInAlbum:collection page:self.photosInAlbumSyncOperationPage sort:self.photosInAlbumSyncOperationSort];
            }
        }
    } else if (collectionType==Tag.class) {
        if (pause) {
            self.pausePhotosInTagSyncOperation = YES;
            [self.photosInTagSyncingOperation cancel];
        }
        else {
            if (self.pausePhotosInTagSyncOperation) {
                self.pausePhotosInTagSyncOperation = NO;
                self.photosInTagSyncingOperation = [self fetchPhotosInTag:collection page:self.photosInTagSyncOperationPage sort:self.photosInTagSyncOperationSort];
            }
        }
    } else {
        if (pause) {
            self.pauseAllPhotosSyncOperation = YES;
            [self.allPhotosSyncingOperation cancel];
        }
        else {
            if (self.pauseAllPhotosSyncOperation) {
                self.pauseAllPhotosSyncOperation = NO;
                self.allPhotosSyncingOperation = [self fetchPhotosForPage:self.allPhotosSyncOperationPage sort:self.allPhotosSyncOperationSort];
            }
        }
    }
}

- (void)pauseSyncingAlbums:(BOOL)pause {
    if (pause) {
        self.pauseAlbumsSyncOperation = YES;
        [self.albumsSyncingOperation cancel];
    } else {
        self.pauseAlbumsSyncOperation = NO;
        if (self.albumsSyncingOperation.state != NSURLSessionTaskStateRunning) {
            self.albumsSyncingOperation = [self fetchAlbumsForPage:self.albumsSyncOperationPage];
        }
    }
}

- (void)pauseSyncingTags:(BOOL)pause {
    if (pause) {
        [self.tagsSyncingOperation cancel];
    } else {
        if (self.tagsSyncingOperation.state != NSURLSessionTaskStateRunning) {
            self.tagsSyncingOperation = [self fetchTagsForPage:1];
        }
    }
}

- (void)refreshPhotosInCollection:(NSString *)collection collectionType:(Class)collectionType sort:(NSString *)sort {
    if (collectionType == Album.class) {
        [self.photosInAlbumSyncingOperation cancel];
        self.pausePhotosInAlbumSyncOperation = NO;
        self.photosInAlbumSyncingOperation = [self fetchPhotosInAlbum:collection page:0 sort:sort];
    } else if (collectionType == Tag.class) {
        [self.photosInTagSyncingOperation cancel];
        self.pausePhotosInTagSyncOperation = NO;
        self.photosInTagSyncingOperation = [self fetchPhotosInTag:collection page:0 sort:sort];
    } else {
        [self.allPhotosSyncingOperation cancel];
        self.pauseAllPhotosSyncOperation = NO;
        self.allPhotosSyncingOperation = [self fetchPhotosForPage:0 sort:sort];
    }
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    //CLS_LOG(@"did receive memory warning");
}

- (void)insertPhotos:(NSArray *)photos completion:(void(^)())completionBlock {
    //
    [self.photosConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (Photo *photo in photos) {
            [transaction setObject:photo forKey:photo.photoId inCollection:photosCollectionName];
        }
    } completionBlock:completionBlock];
    
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kUserLoggedInContext) {
        self.allPhotosSyncOperationPage = 0;
        self.photosInAlbumSyncOperationPage = 0;
        self.photosInTagSyncOperationPage = 0;
        self.albumsSyncOperationPage = 1;
    }
}

#pragma mark - Notifications

- (void)willEnterForeground:(NSNotification *)notification {
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    switch (self.syncOperationType) {
        case SyncOperationTypeAllPhotos:
            [self pauseSyncingPhotos:NO collection:nil collectionType:nil];
            break;
        case SyncOperationTypeTagPhotos:
            [self pauseSyncingPhotos:NO collection:self.photosInTagSyncOperationCollection collectionType:Tag.class];
            break;
        case SyncOperationTypeAlbumPhotos:
            [self pauseSyncingPhotos:NO collection:self.photosInAlbumSyncOperationCollection collectionType:Album.class];
            break;
        case SyncOperationTypeTags:
            [self pauseSyncingTags:NO];
            break;
        case SyncOperationTypeAlbums:
            [self pauseSyncingAlbums:NO];
            break;
        default:
            break;
    }
}

- (void)didEnterBackground:(NSNotification *)notification {
    //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    if (self.allPhotosSyncingOperation && self.allPhotosSyncingOperation.state == NSURLSessionTaskStateRunning) {
        self.syncOperationType = SyncOperationTypeAllPhotos;
    } else if (self.photosInTagSyncingOperation && self.photosInTagSyncingOperation.state == NSURLSessionTaskStateRunning) {
        self.syncOperationType = SyncOperationTypeTagPhotos;
    } else if (self.photosInAlbumSyncingOperation && self.photosInAlbumSyncingOperation.state == NSURLSessionTaskStateRunning) {
        self.syncOperationType = SyncOperationTypeAlbumPhotos;
    } else if (self.albumsSyncingOperation && self.albumsSyncingOperation.state == NSURLSessionTaskStateRunning) {
        self.syncOperationType = SyncOperationTypeAlbums;
    } else if (self.tagsSyncingOperation && self.tagsSyncingOperation.state == NSURLSessionTaskStateRunning) {
        self.syncOperationType = SyncOperationTypeTags;
    } else {
        self.syncOperationType  =SyncOperationTypeNone;
    }
    
    [self pauseSyncingPhotos:YES collection:nil collectionType:nil];
    [self pauseSyncingPhotos:YES collection:nil collectionType:Album.class];
    [self pauseSyncingPhotos:YES collection:nil collectionType:Tag.class];
    [self pauseSyncingTags:YES];
    [self pauseSyncingAlbums:YES];
    
}

@end
