//
//  Album.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PhotoBoxModel.h"

@class Photo;

@interface Album : PhotoBoxModel

@property (nonatomic, copy, readonly) NSNumber *count;
@property (nonatomic, copy, readonly) NSString *albumId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *coverFilenameOriginal;
@property (nonatomic, copy, readonly) NSString *coverId;
@property (nonatomic, copy, readonly) NSURL *coverURL;

+ (Album *)allPhotosAlbum;

@end
