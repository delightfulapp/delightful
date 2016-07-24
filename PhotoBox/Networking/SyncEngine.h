//
//  SyncEngine.h
//  Delightful
//
//  Created by  on 10/13/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_PHOTOS_CACHE_AGE 30*24*60*60

extern NSString *const SyncEngineWillStartInitializingNotification;
extern NSString *const SyncEngineDidFinishInitializingNotification;

extern NSString *const SyncEngineWillStartFetchingNotification;
extern NSString *const SyncEngineDidFinishFetchingNotification;
extern NSString *const SyncEngineDidFailFetchingNotification;

extern NSString *const SyncEngineNotificationResourceKey;
extern NSString *const SyncEngineNotificationIdentifierKey;
extern NSString *const SyncEngineNotificationPageKey;
extern NSString *const SyncEngineNotificationErrorKey;
extern NSString *const SyncEngineNotificationCountKey;

@interface SyncEngine : NSObject

+ (instancetype)sharedEngine;

- (void)startSyncingPhotosInCollection:(NSString *)collection collectionType:(Class)collectionType sort:(NSString *)sort;

- (void)pauseSyncingPhotos:(BOOL)pause collection:(NSString *)collection collectionType:(Class)collectionType;

- (void)refreshPhotosInCollection:(NSString *)collection collectionType:(Class)collectionType sort:(NSString *)sort;

- (void)startSyncingAlbums;

- (void)startSyncingTags;

- (void)refreshResource:(NSString *)resource;

- (void)pauseSyncingAlbums:(BOOL)pause;

- (void)pauseSyncingTags:(BOOL)pause;

@property (nonatomic, assign, readonly) BOOL isSyncingAlbums;
@property (nonatomic, assign, readonly) BOOL isSyncingTags;

@property (nonatomic, strong) NSString *photosSyncSort;

@end
