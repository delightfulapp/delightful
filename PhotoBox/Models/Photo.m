//
//  Photo.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "Photo.h"
#import "Tag.h"
#import "Album.h"
#import "FetchedIn.h"

#import "NSObject+Additionals.h"
#import "NSArray+Additionals.h"

@implementation Photo

@synthesize originalImage = _originalImage;


#pragma mark - Getters

- (PhotoBoxImage *)originalImage {
    if (!_originalImage) {
        _originalImage = [[PhotoBoxImage alloc] initWithArray:@[(self.pathOriginal)?self.pathOriginal.absoluteString:@"", self.width?:@(0), self.height?:@(0)]];
    }
    return _originalImage;
}

- (PhotoBoxImage *)thumbnailImage {
    return self.photo320x320;
}

- (PhotoBoxImage *)normalImage {
    return self.photo640x640;
}

- (NSString *)itemId {
    return self.photoId;
}

- (NSString *)dateTakenString {
    NSString *toReturn = [NSString stringWithFormat:@"%d-%02d-%02d", [self.dateTakenYear intValue], [self.dateTakenMonth intValue], [self.dateTakenDay intValue]];
    return toReturn;
}

- (NSString *)dateMonthYearTakenString {
    return [NSString stringWithFormat:@"%d-%02d", [self.dateTakenYear intValue], [self.dateTakenMonth intValue]];
}

- (NSString *)dimension {
    return [NSString stringWithFormat:@"%dx%d", [self.width intValue], [self.height intValue]];
}

#pragma mark - JSON Serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super class] photoBoxJSONKeyPathsByPropertyKeyWithDictionary:@{
                                                                            @"photoId": @"id",
                                                                            @"photoHash":@"hash",
                                                                            @"photoDescription":@"description",
                                                                            @"dateMonthYearTakenString":NSNull.null
                                                                            }];
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

+ (NSValueTransformer *)photo320x320JSONTransformer {
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

// NOTE: override MTLModel's dictionaryValue to include dateTakenString in managed object serialization. By default, dateTakenString is not serialized because the isa is nil.
- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dict = [[super dictionaryValue] mutableCopy];
    [dict setObject:[self dateTakenString] forKey:@"dateTakenString"];
    return dict;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[Photo class]]) {
        return NO;
    }
    
    return [self isEqualToPhoto:object];
}

- (BOOL)isEqualToPhoto:(Photo *)photo {
    return [self.photoId isEqualToString:photo.photoId];
}

- (NSUInteger)hash {
    return [self.photoHash intValue];
}

@end
