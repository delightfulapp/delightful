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

@class Photo;

@interface Album : PhotoBoxModel

@property (nonatomic, copy, readonly) NSNumber *count;
@property (nonatomic, copy, readonly) NSString *albumId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) Photo *cover;

- (NSURL *)albumCover:(AlbumCoverType)coverType;

+ (Album *)allPhotosAlbum;

@end
