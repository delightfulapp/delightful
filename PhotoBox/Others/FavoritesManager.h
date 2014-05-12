//
//  FavoritesManager.h
//  Delightful
//
//  Created by Nico Prananta on 5/12/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DownloadedImageManager.h"

@interface FavoritesManager : DownloadedImageManager

- (BOOL)photoHasBeenFavorited:(Photo *)photo;

@end
