//
//  SyncEngine.h
//  Delightful
//
//  Created by  on 10/13/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SyncEngineWillStartFetchingNotification;
extern NSString *const SyncEngineDidFinishFetchingNotification;
extern NSString *const SyncEngineDidFailFetchingNotification;

extern NSString *const SyncEngineNotificationResourceKey;
extern NSString *const SyncEngineNotificationPageKey;
extern NSString *const SyncEngineNotificationErrorKey;
extern NSString *const SyncEngineNotificationCountKey;

@interface SyncEngine : NSObject

+ (instancetype)sharedEngine;

- (void)startSyncingPhotos;

- (void)startSyncingAlbums;

- (void)startSyncingTags;

- (void)refreshResource:(NSString *)resource;

@property (nonatomic, assign, readonly) BOOL isSyncingPhotos;
@property (nonatomic, assign, readonly) BOOL isSyncingAlbums;
@property (nonatomic, assign, readonly) BOOL isSyncingTags;

@property (nonatomic, assign) BOOL pausePhotosSync;
@property (nonatomic, assign) BOOL pauseAlbumsSync;
@property (nonatomic, assign) BOOL pauseTagsSync;

@property (nonatomic, strong) NSString *photosSyncSort;

@end
