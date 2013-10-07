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

@implementation Photo

@synthesize originalImage = _originalImage;


#pragma mark - Getters

- (PhotoBoxImage *)originalImage {
    if (!_originalImage) {
        _originalImage = [[PhotoBoxImage alloc] initWithArray:@[(self.pathOriginal)?self.pathOriginal.absoluteString:@"", self.width, self.height]];
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
    NSString *toReturn = [NSString stringWithFormat:@"%d-%02d-%02d", [self.dateTakenYear intValue], [self.dateTakenMonth intValue], [self.dateTakenDay intValue]];
    return toReturn;
}

- (NSString *)dateMonthYearTakenString {
    return [NSString stringWithFormat:@"%d-%02d", [self.dateTakenYear intValue], [self.dateTakenMonth intValue]];
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

// NOTE: override MTLModel's dictionaryValue to include dateTakenString in managed object serialization. By default, dateTakenString is not serialized because the isa is nil.
- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dict = [[super dictionaryValue] mutableCopy];
    [dict setObject:[self dateTakenString] forKey:@"dateTakenString"];
    return dict;
}

#pragma mark - Managed object serialization

+ (NSString *)managedObjectEntityName {
    return [[self class] photoBoxManagedObjectEntityNameForClassName:NSStringFromClass([self class])];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return [[super class] photoBoxManagedObjectKeyPathsByPropertyKeyWithDictionary:@{@"thumbnailImage": NSNull.null, @"normalImage": NSNull.null, @"originalImage": NSNull.null, @"dateMonthYearTakenString":NSNull.null, @"dateTakenString":@"dateTakenString"}];
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"photoId"];
}

+ (NSValueTransformer *)entityAttributeTransformerForKey:(NSString *)key {
    if ([[[self class] propertyTypeStringForPropertyName:key] isEqualToString:@"NSURL"]) {
        return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    } else if ([[[self class] propertyTypeStringForPropertyName:key] isEqualToString:@"NSArray"]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *arrays) {
            return [arrays componentsJoinedByString:@"||"];
        } reverseBlock:^id(NSString *stringArray) {
            return [stringArray componentsSeparatedByString:@"||"];
        }];
    }
    return nil;
}

+ (NSDictionary *)relationshipModelClassesByPropertyKey {
    return @{ @"photo200x200xCR":PhotoBoxImage.class, @"photo640x640":PhotoBoxImage.class};
}

@end
