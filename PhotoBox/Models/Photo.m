//
//  Photo.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "Photo.h"
#import "Tag.h"

@implementation Photo

@synthesize photoId = id;

- (void)setTags:(NSArray *)tags {
    NSMutableArray *array = [NSMutableArray array];
    for (id tag in tags) {
        Tag *t;
        if ([tag isKindOfClass:[NSDictionary class]]) {
            t = [[Tag alloc] initWithDictionary:tag];
        } else if ([tag isKindOfClass:[NSString class]]) {
            t = [[Tag alloc] initWithDictionary:@{@"id": tag}];
        }
        
        if (t) {
            [array addObject:t];
        }
    }
    _tags = array;
}

- (void)setPhoto200x200xCR:(NSArray *)photo200x200xCR {
    _photo200x200xCR = photo200x200xCR;
    self.thumbnailStringURL = [photo200x200xCR objectAtIndex:0];
}

@end
