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

@interface SyncEngine ()

@property (nonatomic, strong) YapDatabase *database;

@property (nonatomic, strong) YapDatabaseConnection *bgConnection;

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
        
        self.bgConnection = [self.database newConnection];
        self.bgConnection.objectCacheEnabled = NO; // don't need cache for write-only connection
        self.bgConnection.metadataCacheEnabled = NO;
    }
    return self;
}

- (void)startSyncing {
    [self fetchAlbumsForPage:1];
    //[self fetchPhotosForPage:0];
    //[self fetchTagsForPage:1];
}

- (void)fetchTagsForPage:(int)page {
    NSLog(@"Fetching tags page %d", page);
    [[PhotoBoxClient sharedClient] getTagsForPage:page pageSize:0 success:^(NSArray *tags) {
        NSLog(@"Did finish fetching %d tags page %d", (int)tags.count, page);
        if (tags.count > 0) {
            [self.bgConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                for (Tag *tag in tags) {
                    [transaction setObject:tag forKey:tag.tagId inCollection:tagsCollectionName];
                }
            } completionBlock:^{
                NSLog(@"Done inserting tags to db");
            }];
        }
    } failure:^(NSError *error) {
        NSLog(@"Error fetching tags page %d: %@", page, error);
    }];
}

- (void)fetchAlbumsForPage:(int)page {
    NSLog(@"Fetching albums page %d", page);
    [[PhotoBoxClient sharedClient] getAlbumsForPage:page pageSize:FETCHING_PAGE_SIZE success:^(NSArray *albums) {
        NSLog(@"Did finish fetching %d albums page %d", (int)albums.count, page);
        if (albums.count > 0) {
            [self.bgConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                for (Album *album in albums) {
                    [transaction setObject:album forKey:album.albumId inCollection:albumsCollectionName];
                }
            } completionBlock:^{
                NSLog(@"Done inserting albums to db");
            }];
            
            [self fetchAlbumsForPage:page+1];
        }
    } failure:^(NSError *error) {
        NSLog(@"Error fetching albums page %d: %@", page, error);
    }];
}

- (void)syncTags {
    
}

- (void)fetchPhotosForPage:(int)page {
    NSLog(@"Fetching photos for page %d", page);
    [[PhotoBoxClient sharedClient] getPhotosForPage:page pageSize:FETCHING_PAGE_SIZE success:^(NSArray *photos) {
        NSLog(@"Did finish fetching %d photos page %d", (int)photos.count, page);
        if (photos.count > 0) {
            [self.bgConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                for (Photo *photo in photos) {
                    [transaction setObject:photo forKey:photo.photoId inCollection:photosCollectionName];
                }
            } completionBlock:^{
                NSLog(@"Done inserting photos to db");
            }];
            
            [self fetchPhotosForPage:page+1];
        }
    } failure:^(NSError *error) {
        NSLog(@"Error fetching photos page %d: %@", page, error);
    }];
}

@end
