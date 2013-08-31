//
//  Album.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "Album.h"

@implementation Album

@synthesize albumId = id;

- (NSURL *)albumCover:(AlbumCoverType)coverType {
    NSDictionary *cover = [self.rawDictionary objectForKey:@"cover"];
    return [NSURL URLWithString:[cover objectForKey:stringWithAlbumCoverType(coverType)]];
}

NSString *stringWithAlbumCoverType(AlbumCoverType input) {
    NSArray *arr = @[
                     @"path100x100",
                     @"path100x100xCR",
                     @"path200x200",
                     @"path200x200xCR",
                     @"pathOriginal"
                     ];
    return (NSString *)[arr objectAtIndex:input];
}

- (NSString *)itemId {
    return self.albumId;
}

@end
