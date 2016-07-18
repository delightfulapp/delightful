//
//  Album.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "Album.h"

#import "Photo.h"

#import "DownloadedImageManager.h"

#import "FavoritesManager.h"

#import "AppDelegate.h"

NSString *PBX_allAlbumIdentifier = @"PBX_ALL";
NSString *PBX_downloadHistoryIdentifier = @"PBX_DOWNLOADED_HISTORY_ALBUM";
NSString *PBX_favoritesAlbumIdentifier = @"PBX_FAVORITES_ALBUM";

@implementation Album

- (id)initWithItemId:(NSString *)itemId{
    self = [super init];
    if (self) {
        _albumId = itemId;
    }
    return self;
}

- (NSString *)itemId {
    return self.albumId;
}

- (NSString *)titleName {
    return self.name;
}

+ (Album *)allPhotosAlbum {
    NSError *error;
    Album *a = [MTLJSONAdapter modelOfClass:[Album class] fromJSONDictionary:@{
                                                                               @"id": PBX_allAlbumIdentifier,
                                                                               @"name":NSLocalizedString(@"Gallery", nil),
                                                                               @"cover":@{@"id": @"COVER_PHOTO_ALL_ALBUM", @"filenameOriginal":@""}
                                                                               } error:&error];
    return a;
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mtl_dictionaryByAddingEntriesFromDictionary:[[super class] photoBoxJSONKeyPathsByPropertyKeyWithDictionary:@{
                                                                                                                                                                                      @"albumId": @"id",
                                                                                                                                                                                      @"coverId":@"cover.id",
                                                                                                                                                                                @"coverURL":@"cover.path200x200xCR",
                                                                                                                                                                                      @"albumCover": @"cover"
                                                                                                                                                                                      }]];
}

+ (NSValueTransformer *)albumCoverJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[Photo class]];
}



@end
