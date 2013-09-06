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
    PhotoBoxImage *image = [[PhotoBoxImage alloc] initWithArray:photo200x200xCR];
    self.thumbnailImage = image;
}

- (void)setPhoto640x640:(NSArray *)photo640x640 {
    PhotoBoxImage *image = [[PhotoBoxImage alloc] initWithArray:photo640x640];
    self.normalImage = image;
}

- (void)setPathOriginal:(NSString *)pathOriginal {
    if (_pathOriginal != pathOriginal) {
        _pathOriginal = pathOriginal;
        [self setOriginalImagePath:pathOriginal];
    }
}

- (void)setWidth:(CGFloat)width {
    _width = width;
    [self setOriginalImageWidth:width];
}

- (void)setHeight:(CGFloat)height {
    _height = height;
    [self setOriginalImageHeight:height];
}

- (PhotoBoxImage *)originalImage {
    if (!_originalImage) {
        _originalImage = [[PhotoBoxImage alloc] init];
        [_originalImage setPhoto:self];
    }
    return _originalImage;
}

- (void)setOriginalImagePath:(NSString *)path {
    [self.originalImage setUrlString:path];
}

- (void)setOriginalImageHeight:(CGFloat)height {
    [self.originalImage setHeight:height];
}

- (void)setOriginalImageWidth:(CGFloat)width {
    [self.originalImage setWidth:width];
}

- (NSString *)itemId {
    return self.photoId;
}

- (NSString *)dateTakenString {
    return [NSString stringWithFormat:@"%d-%02d-%02d", self.dateTakenYear, self.dateTakenMonth, self.dateTakenDay];
}

- (NSString *)dateMonthYearTakenString {
    return [NSString stringWithFormat:@"%d-%02d", self.dateTakenYear, self.dateTakenMonth];
}

@end
