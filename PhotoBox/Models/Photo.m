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

#import "NSObject+Additionals.h"
#import "NSArray+Additionals.h"
#import "MTLModel+NSCoding.h"
#import "NSDate+Escort.h"

@implementation Photo

@synthesize originalImage = _originalImage;
@synthesize pathBaseImage = _pathBaseImage;

#pragma mark - NSCoding

+ (NSDictionary *)encodingBehaviorsByPropertyKey {
    NSMutableDictionary *superBehaviour = [[super encodingBehaviorsByPropertyKey] mutableCopy];
    [self ignorePropertyInBehaviour:superBehaviour propertyKey:NSStringFromSelector(@selector(placeholderImage))];
    [self ignorePropertyInBehaviour:superBehaviour propertyKey:NSStringFromSelector(@selector(asAlbumCoverImage))];
    
    return superBehaviour;
}

+ (void)ignorePropertyInBehaviour:(NSMutableDictionary *)behaviour propertyKey:(NSString *)propertyKey {
    if ([behaviour objectForKey:propertyKey]) {
        [behaviour setObject:@(MTLModelEncodingBehaviorExcluded) forKey:propertyKey];
    }
}

#pragma mark - Getters

- (CLLocation *)clLocation {
    NSNumber *latitude = self.latitude;
    NSNumber *longitude = self.longitude;
    CLLocation *location;
    if (latitude && ![latitude isKindOfClass:[NSNull class]] && longitude && ![longitude isKindOfClass:[NSNull class]]) {
        location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    }
    return location;
}

- (PhotoBoxImage *)originalImage {
    if (!_originalImage) {
        _originalImage = [[PhotoBoxImage alloc] initWithArray:@[(self.pathOriginal)?self.pathOriginal.absoluteString:@"", self.width?:@(0), self.height?:@(0)]];
    }
    return _originalImage;
}

- (PhotoBoxImage *)pathBaseImage {
    if (!_pathBaseImage) {
        _pathBaseImage = [[PhotoBoxImage alloc] initWithArray:@[(self.pathBase)?self.pathBase.absoluteString:@"", self.width?:@(0), self.height?:@(0)]];
    }
    return _pathBaseImage;
}

- (PhotoBoxImage *)thumbnailImage {
    if (self.photo320x320) return self.photo320x320;
    else if (self.photo200x200) return self.photo200x200;
    else if (self.photo100x100) return self.photo100x100;
    return nil;
}

- (PhotoBoxImage *)normalImage {
    if (IS_IPAD) {
        return self.pathBaseImage;
    }
    return self.photo640x640;
}

- (NSString *)itemId {
    return self.photoId;
}

- (NSString *)dateTakenString {
    NSString *toReturn = [NSString stringWithFormat:@"%d-%02d-%02d", [self.dateTakenYear intValue], [self.dateTakenMonth intValue], [self.dateTakenDay intValue]];
    return toReturn;
}

- (NSString *)dateUploadedString {
    NSString *toReturn = [NSString stringWithFormat:@"%d-%02d-%02d", [self.dateUploadedYear intValue], [self.dateUploadedMonth intValue], [self.dateUploadedDay intValue]];
    return toReturn;
}

- (NSDate *)dateUploadedDate {
    return [NSDate dateWithTimeIntervalSince1970:self.dateUploaded.intValue];
}

- (NSDate *)dateTakenDate {
    return [NSDate dateWithTimeIntervalSince1970:self.dateTaken.intValue];
}

- (NSString *)dateMonthYearTakenString {
    return [NSString stringWithFormat:@"%d-%02d", [self.dateTakenYear intValue], [self.dateTakenMonth intValue]];
}

- (NSString *)dateTimeTakenLocalizedString {
    return [NSDateFormatter localizedStringFromDate:[self dateTakenDate] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)dimension {
    return [NSString stringWithFormat:@"%dx%d", [self.width intValue], [self.height intValue]];
}

- (NSString *)latitudeLongitudeString {
    if (self.latitude && self.longitude) {
        return [NSString stringWithFormat:@"%@,%@", self.latitude, self.longitude];
    }
    return nil;
}

#pragma mark - JSON Serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mtl_dictionaryByAddingEntriesFromDictionary:[[super class] photoBoxJSONKeyPathsByPropertyKeyWithDictionary:@{
                                                                                                                                                                                                        @"photoId": @"id",
                                                                                                                                                                                                        @"photoHash":@"hash",
                                                                                                                                                                                                        @"photoDescription":@"description"
                                                                                                                                                                                                        }]];
}

+ (NSValueTransformer *)timestampJSONTransformer {
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    });
    
    return  [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *string, BOOL *success, NSError *__autoreleasing *error) {
        return [dateFormatter dateFromString:string];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return value;
    }];
}

+ (NSValueTransformer *)photo320x320JSONTransformer {
    return [[self class] photoImageTransformer];
}

+ (NSValueTransformer *)photo640x640JSONTransformer {
    return [[self class] photoImageTransformer];
}

+ (NSValueTransformer *)photo100x100JSONTransformer {
    return [[self class] photoImageTransformer];
}

+ (NSValueTransformer *)photo200x200JSONTransformer {
    return [[self class] photoImageTransformer];
}

+ (MTLValueTransformer *)photoImageTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *imageArray, BOOL *success, NSError *__autoreleasing *error) {
        return [[PhotoBoxImage alloc] initWithArray:imageArray];
    } reverseBlock:^id(PhotoBoxImage *image, BOOL *success, NSError *__autoreleasing *error) {
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
