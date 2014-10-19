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

#import <YapDatabase.h>

#define FETCHING_PAGE_SIZE 100

#define DEFAULT_PHOTOS_SORT @"dateUploaded,desc"

NSString *const SyncEngineWillStartFetchingNotification = @"com.getdelightfulapp.SyncEngineWillStartFetchingNotification";
NSString *const SyncEngineDidFinishFetchingNotification = @"com.getdelightfulapp.SyncEngineDidFinishFetchingNotification";
NSString *const SyncEngineDidFailFetchingNotification = @"com.getdelightfulapp.SyncEngineDidFailFetchingNotification";

NSString *const SyncEngineNotificationResourceKey = @"resource";
NSString *const SyncEngineNotificationPageKey = @"page";
NSString *const SyncEngineNotificationErrorKey = @"error";
NSString *const SyncEngineNotificationCountKey = @"count";

@interface SyncEngine ()

@property (nonatomic, strong) YapDatabase *database;

@property (nonatomic, strong) YapDatabaseConnection *photosConnection;

@property (nonatomic, strong) YapDatabaseConnection *albumsConnection;

@property (nonatomic, strong) YapDatabaseConnection *tagsConnection;

@property (nonatomic, assign) int albumsFetchingPage;

@property (nonatomic, assign) int photosFetchingPage;

@property (nonatomic, assign) BOOL tagsRefreshRequested;

@property (nonatomic, assign) BOOL albumsRefreshRequested;

@property (nonatomic, assign) BOOL photosRefreshRequested;

@property (nonatomic, assign) BOOL isSyncingPhotos;
@property (nonatomic, assign) BOOL isSyncingAlbums;
@property (nonatomic, assign) BOOL isSyncingTags;

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
    }
    return self;
}

- (void)startSyncingPhotos {
    if (!self.isSyncingPhotos) {
        [self fetchPhotosForPage:0 sort:DEFAULT_PHOTOS_SORT];
    } else {
        [self refreshResource:NSStringFromClass([Photo class])];
    }
}

- (void)startSyncingAlbums {
    if (!self.isSyncingAlbums) {
        [self fetchAlbumsForPage:1];
    } else {
        [self refreshResource:NSStringFromClass([Album class])];
    }
}

- (void)startSyncingTags {
    if (!self.isSyncingTags) {
        [self fetchTagsForPage:1];
    } else {
        [self refreshResource:NSStringFromClass([Tag class])];
    }
}

- (void)refreshResource:(NSString *)resource {
    if ([resource isEqualToString:NSStringFromClass([Tag class])]) {
        self.tagsRefreshRequested = (!self.isSyncingTags)?YES:NO;
    } else if ([resource isEqualToString:NSStringFromClass([Album class])]) {
        self.albumsRefreshRequested = (!self.isSyncingAlbums)?YES:NO;
    } else if ([resource isEqualToString:NSStringFromClass([Photo class])]) {
        self.photosRefreshRequested = !(self.isSyncingPhotos)?YES:NO;
    }
}

- (void)setPauseSync:(BOOL)pauseSync {
    _pauseSync = pauseSync;
    
    if (!_pauseSync) {
        [self fetchPhotosForPage:self.photosFetchingPage sort:DEFAULT_PHOTOS_SORT];
        [self fetchAlbumsForPage:self.albumsFetchingPage];
    }
}

- (void)fetchPhotosWithSort:(NSString *)sort {
    if (!self.isSyncingPhotos) {
        self.pauseSync = YES;
        [self fetchPhotosForPage:self.photosFetchingPage+1 sort:sort];
    }
    
}

- (void)fetchTagsForPage:(int)page {
    NSLog(@"Fetching tags page %d", page);
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page)}];
    self.isSyncingTags = YES;
    
    [[PhotoBoxClient sharedClient] getTagsForPage:page pageSize:0 success:^(NSArray *tags) {
        NSLog(@"Did finish fetching %d tags page %d", (int)tags.count, page);
        if (tags.count > 0) {
            [self.tagsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                for (Tag *tag in tags) {
                    [transaction setObject:tag forKey:tag.tagId inCollection:tagsCollectionName];
                }
            } completionBlock:^{
                NSLog(@"Done inserting tags to db");
            }];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationCountKey: @(tags.count)}];
        self.isSyncingTags = NO;
        
        if (self.tagsRefreshRequested) {
            self.tagsRefreshRequested = NO;
            [self fetchTagsForPage:0];
        }
    } failure:^(NSError *error) {
        NSLog(@"Error fetching tags page %d: %@", page, error);
        self.isSyncingTags = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page)}];
    }];
}

- (void)fetchAlbumsForPage:(int)page {
    NSLog(@"Fetching albums page %d", page);
    self.isSyncingAlbums = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page)}];
    
    [[PhotoBoxClient sharedClient] getAlbumsForPage:page pageSize:FETCHING_PAGE_SIZE success:^(NSArray *albums) {
        NSLog(@"Did finish fetching %d albums page %d", (int)albums.count, page);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationCountKey: @(albums.count)}];
        
        if (albums.count > 0) {
            [self.albumsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                for (Album *album in albums) {
                    [transaction setObject:album forKey:album.albumId inCollection:albumsCollectionName];
                }
            } completionBlock:^{
                NSLog(@"Done inserting albums to db");
            }];
            
            if (self.albumsRefreshRequested) {
                self.albumsRefreshRequested = NO;
                [self fetchAlbumsForPage:1];
            } else {
                if (self.pauseSync) {
                    self.albumsFetchingPage = page;
                } else {
                    [self fetchAlbumsForPage:page+1];
                }
            }
        } else {
            self.isSyncingAlbums = NO;
            self.albumsFetchingPage = 0;
        }
    } failure:^(NSError *error) {
        NSLog(@"Error fetching albums page %d: %@", page, error);
        self.isSyncingAlbums = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page)}];
        self.albumsFetchingPage = page;
    }];
}

- (void)fetchPhotosForPage:(int)page sort:(NSString *)sort{
    NSLog(@"Fetching photos for page %d", page);
    self.isSyncingPhotos = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page)}];
    
    [[PhotoBoxClient sharedClient] getPhotosForPage:page sort:sort pageSize:FETCHING_PAGE_SIZE success:^(NSArray *photos) {
        NSLog(@"Did finish fetching %d photos page %d", (int)photos.count, page);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFinishFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page), SyncEngineNotificationCountKey: @(photos.count)}];
        
        if (photos.count > 0) {
            [self.photosConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                for (Photo *photo in photos) {
                    [transaction setObject:photo forKey:photo.photoId inCollection:photosCollectionName];
                }
            } completionBlock:^{
                NSLog(@"Done inserting photos to db");
            }];
            
            if (self.photosRefreshRequested) {
                self.photosRefreshRequested = NO;
                [self fetchPhotosForPage:0 sort:sort];
            } else {
                if (self.pauseSync) {
                    self.photosFetchingPage = page;
                    self.isSyncingPhotos = NO;
                } else {
                    [self fetchPhotosForPage:page+1 sort:sort];
                }
            }
        } else {
            self.isSyncingPhotos = NO;
            self.photosFetchingPage = 0;
        }
    } failure:^(NSError *error) {
        NSLog(@"Error fetching photos page %d: %@", page, error);
        self.isSyncingPhotos = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page)}];
        self.photosFetchingPage = page;
    }];
}

@end
