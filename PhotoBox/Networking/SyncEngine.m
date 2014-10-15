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

- (void)startSyncing {
    [self fetchAlbumsForPage:1];
    [self fetchPhotosForPage:0];
    [self fetchTagsForPage:1];
}

- (void)setPauseSync:(BOOL)pauseSync {
    _pauseSync = pauseSync;
    
    if (!_pauseSync) {
        [self fetchPhotosForPage:self.photosFetchingPage];
        [self fetchAlbumsForPage:self.albumsFetchingPage];
    }
}

- (void)fetchTagsForPage:(int)page {
    NSLog(@"Fetching tags page %d", page);
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page)}];
    
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
    } failure:^(NSError *error) {
        NSLog(@"Error fetching tags page %d: %@", page, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Tag class]), SyncEngineNotificationPageKey: @(page)}];
    }];
}

- (void)fetchAlbumsForPage:(int)page {
    NSLog(@"Fetching albums page %d", page);
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
            
            if (self.pauseSync) {
                self.albumsFetchingPage = page;
            } else {
                [self fetchAlbumsForPage:page+1];
            }
        } else {
            self.albumsFetchingPage = 0;
        }
    } failure:^(NSError *error) {
        NSLog(@"Error fetching albums page %d: %@", page, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Album class]), SyncEngineNotificationPageKey: @(page)}];
        self.albumsFetchingPage = page;
    }];
}

- (void)fetchPhotosForPage:(int)page {
    NSLog(@"Fetching photos for page %d", page);
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineWillStartFetchingNotification object:nil userInfo:@{SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page)}];
    
    [[PhotoBoxClient sharedClient] getPhotosForPage:page pageSize:FETCHING_PAGE_SIZE success:^(NSArray *photos) {
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
            
            if (self.pauseSync) {
                self.photosFetchingPage = page;
            } else {
                [self fetchPhotosForPage:page+1];
            }
        } else {
            self.photosFetchingPage = 0;
        }
    } failure:^(NSError *error) {
        NSLog(@"Error fetching photos page %d: %@", page, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncEngineDidFailFetchingNotification object:nil userInfo:@{SyncEngineNotificationErrorKey: error, SyncEngineNotificationResourceKey: NSStringFromClass([Photo class]), SyncEngineNotificationPageKey: @(page)}];
        self.photosFetchingPage = page;
    }];
}

@end
