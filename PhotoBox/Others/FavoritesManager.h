//
//  FavoritesManager.h
//  Delightful
//
//  Created by Nico Prananta on 5/12/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DownloadedImageManager.h"
#import <Bolts.h>

extern NSString *const favoritesTagName;

@interface FavoritesManager : DownloadedImageManager

- (BOOL)photoHasBeenFavorited:(Photo *)photo;
- (BFTask *)addPhoto:(Photo *)photo;
- (BFTask *)removePhoto:(Photo *)photo;
- (BFTask *)addPhotoWithId:(NSString *)photo;
- (BFTask *)removePhotoWithId:(NSString *)photo;

@end
