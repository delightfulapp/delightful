//
//  FavoritesManager.m
//  Delightful
//
//  Created by Nico Prananta on 5/12/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "FavoritesManager.h"

#import "DLFDatabaseManager.h"

#define kFavoritesManagerKey @"com.delightful.kFavoritesManagerKey"

@implementation FavoritesManager

+ (instancetype)sharedManager {
    static FavoritesManager *_sharedFavoritesManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFavoritesManager = [[FavoritesManager alloc] init];
    });
    
    return _sharedFavoritesManager;
}

- (NSString *)downloadedImageKey {
    return kFavoritesManagerKey;
}

- (NSString *)photosCollectionName {
    return favoritedPhotosCollectionName;
}

- (BOOL)photoHasBeenFavorited:(Photo *)photo {
    return [self photoHasBeenDownloaded:photo];
}

@end
