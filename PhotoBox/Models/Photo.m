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
    return [[super class] photoBoxJSONKeyPathsByPropertyKeyWithDictionary:@{@"photoId": @"id",@"photoHash":@"hash",@"photoDescription":@"description", @"dateMonthYearTakenString":NSNull.null}];
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
    return [[self class] transformerForClass:[Tag class]];
}

+ (NSValueTransformer *)albumsJSONTransformer {
    return [[self class] transformerForClass:[Album class]];
}


+ (MTLValueTransformer *)transformerForClass:(Class)class {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *items){
        NSMutableArray *itemObjects = [NSMutableArray arrayWithCapacity:items.count];
        for (NSString *item in items) {
            [itemObjects addObject:[[class alloc] initWithItemId:item]];
        }
        return itemObjects;
    } reverseBlock:^(NSArray *itemsObjects) {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:itemsObjects.count];
        for (PhotoBoxModel *item in itemsObjects) {
            [items addObject:item.itemId];
        }
        return items;
    }];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    NSString *keyType = [[self class] propertyTypeStringForPropertyName:key];
    if ([keyType isEqualToString:@"NSNumber"]) {
        return [[self class] toNumberTransformer];
    } else if ([keyType isEqualToString:@"NSString"]) {
        return [[self class] toStringTransformer];
    }
    return nil;
}

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
    if ([key isEqualToString:@"url"] || [key isEqualToString:@"pathOriginal"]) {
        return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    }
    return nil;
}

+ (NSDictionary *)relationshipModelClassesByPropertyKey {
    return @{@"albums": Album.class, @"tags": Tag.class, @"photo200x200xCR":PhotoBoxImage.class, @"photo640x640":PhotoBoxImage.class};
}

- (BOOL)validateValue:(inout __autoreleasing id *)ioValue forKey:(NSString *)inKey error:(out NSError *__autoreleasing *)outError {
    if ([inKey hasPrefix:@"date"]) {
        if (!ioValue) {
            return NO;
        }
        return YES;
    }
    return YES;
}

@end
