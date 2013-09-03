//
//  Album.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AlbumCoverType) {
    path100x100,
    path100x100xCR,
    path200x200,
    path200x200xCR,
    pathOriginal
};

#import "PhotoBoxModel.h"

@interface Album : PhotoBoxModel

@property (nonatomic, assign) int count;
@property (nonatomic, strong) NSString *albumId;
@property (nonatomic, strong) NSString *name;

- (NSURL *)albumCover:(AlbumCoverType)coverType;

+ (Album *)allPhotosAlbum;

@end
