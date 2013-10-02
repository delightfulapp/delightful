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

#pragma mark - JSON Serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super class] photoBoxKeyPathsByPropertyKeyWithDictionary:@{@"photoId": @"id",@"photoHash":@"hash",@"photoDescription":@"description",@"dateTakenString":NSNull.null, @"dateMonthYearTakenString":NSNull.null}];
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
    NSArray *stringToNumberKeys = @[@"height", @"width", @"size", @"views"];
    if ([key hasPrefix:@"date"] || [stringToNumberKeys containsObject:key]) {
        return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *string){
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            return [f numberFromString:string];
        } reverseBlock:^(NSNumber *number){
            return [NSString stringWithFormat:@"%d", [number intValue]];
        }];
    }
    return nil;
}

#pragma mark - Managed object serialization

+ (NSString *)managedObjectEntityName {
    return [[self class] photoBoxManagedObjectEntityNameForClassName:NSStringFromClass([self class])];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return [[super class] photoBoxKeyPathsByPropertyKeyWithDictionary:@{@"thumbnailImage": NSNull.null, @"normalImage": NSNull.null, @"originalImage": NSNull.null, @"dateTakenString": NSNull.null, @"dateMonthYearTakenString":NSNull.null}];
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
    return @{@"albums": Album.class, @"tags": Tag.class};
}

@end
