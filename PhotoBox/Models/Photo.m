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

@synthesize originalImage = _originalImage;


#pragma mark - Getters

- (PhotoBoxImage *)originalImage {
    if (!_originalImage) {
        _originalImage = [[PhotoBoxImage alloc] initWithArray:@[self.pathOriginal.absoluteString, self.width, self.height]];
    }
    return _originalImage;
}

- (PhotoBoxImage *)thumbnailImage {
    return self.photo200x200xCR;
}

- (PhotoBoxImage *)normalImage {
    return self.photo640x640;
}

- (NSString *)itemId {
    return self.photoId;
}

- (NSString *)dateTakenString {
    return [NSString stringWithFormat:@"%d-%02d-%02d", [self.dateTakenYear intValue], [self.dateTakenMonth intValue], [self.dateTakenDay intValue]];
}

- (NSString *)dateMonthYearTakenString {
    return [NSString stringWithFormat:@"%d-%02d", [self.dateTakenYear intValue], [self.dateTakenMonth intValue]];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"photoId": @"id"};
}

+ (NSValueTransformer *)timestampJSONTransformer {
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    });
    
    return [MTLValueTransformer transformerWithBlock:^id(NSString *string) {
        return [dateFormatter dateFromString:string];
    }];
}

+ (NSValueTransformer *)urlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)pathOriginalJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)photo200x200xCRJSONTransformer {
    return [[self class] photoImageTransformer];
}

+ (NSValueTransformer *)photo640x640JSONTransformer {
    return [[self class] photoImageTransformer];
}

+ (MTLValueTransformer *)photoImageTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *imageArray) {
        return [[PhotoBoxImage alloc] initWithArray:imageArray];
    } reverseBlock:^(PhotoBoxImage *image) {
        return [image toArray];
    }];
}

+ (NSValueTransformer *)tagsJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *tags){
        NSMutableArray *tagObjects = [NSMutableArray arrayWithCapacity:tags.count];
        for (NSString *tag in tags) {
            [tagObjects addObject:[[Tag alloc] initWithTagId:tag]];
        }
        return tagObjects;
    } reverseBlock:^(NSArray *tagsObjects) {
        NSMutableArray *tags = [NSMutableArray arrayWithCapacity:tagsObjects.count];
        for (Tag *tag in tagsObjects) {
            [tags addObject:tag.tagId];
        }
        return tags;
    }];
}

@end
