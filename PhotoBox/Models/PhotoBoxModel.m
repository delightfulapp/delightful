//
//  PhotoBoxModel.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxModel.h"

#import "Album.h"
#import "Photo.h"
#import "Tag.h"

#import "NSObject+Additionals.h"

#import "NSDate+Escort.h"

@implementation PhotoBoxModel

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
    if (JSONDictionary[@"cover"] != nil) {
        return Album.class;
    }
    if (JSONDictionary[@"filenameOriginal"] != nil) {
        return Photo.class;
    }
    if (JSONDictionary[@"actor"] != nil && JSONDictionary[@"count"] != nil && JSONDictionary[@"owner"] != nil) {
        return Tag.class;
    }
    NSAssert(NO, @"No matching class for the JSON dictionary '%@'.", JSONDictionary);
    return self;
}

- (id)initWithItemId:(NSString *)itemId {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (NSString *)photoBoxManagedObjectEntityNameForClassName:(NSString *)className {
    return [NSString stringWithFormat:@"PBX%@", className];
}

#pragma mark - JSON serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

+ (NSValueTransformer *)toNumberTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id exifFNumber, BOOL *success, NSError *__autoreleasing *error) {
        if ([exifFNumber isKindOfClass:[NSString class]]) {
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            return [f numberFromString:exifFNumber];
        }
        return exifFNumber;
    } reverseBlock:^id(NSNumber *exifFNumber, BOOL *success, NSError *__autoreleasing *error) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        return [f stringFromNumber:exifFNumber];
    }];
}

+ (NSValueTransformer *)toStringTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id exifFNumber, BOOL *success, NSError *__autoreleasing *error) {
        if ([exifFNumber isKindOfClass:[NSString class]]) {
            return exifFNumber;
        }
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        return [f stringFromNumber:exifFNumber];
    } reverseBlock:^id(NSString *exifFNumber, BOOL *success, NSError *__autoreleasing *error) {
        return exifFNumber;
    }];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    NSString *keyType = [[self class] propertyTypeStringForPropertyName:key];
    if ([keyType isEqualToString:@"NSNumber"]) {
        return [[self class] toNumberTransformer];
    } else if ([keyType isEqualToString:@"NSString"]) {
        return [[self class] toStringTransformer];
    } else if ([keyType isEqualToString:@"NSURL"]) {
        return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    }
    return nil;
}

+ (NSDictionary *)photoBoxJSONKeyPathsByPropertyKeyWithDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:[PhotoBoxModel JSONKeyPathsByPropertyKey]];
    [mutableDict removeObjectsForKeys:@[@"totalRows", @"totalPages", @"currentPage", @"currentRow"]];
    if (dictionary) [mutableDict addEntriesFromDictionary:dictionary];
    return mutableDict;
}


@end
