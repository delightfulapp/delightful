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

@implementation PhotoBoxModel

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
    if (JSONDictionary[@"cover"] != nil) {
        return Album.class;
    }
    if (JSONDictionary[@"filenameOriginal"] != nil) {
        return Photo.class;
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
    return @{@"totalRows": NSNull.null, @"totalPages": NSNull.null, @"currentPage": NSNull.null, @"currentRow": NSNull.null, @"itemId": NSNull.null};
}

#pragma mark - Managed object serialization

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return [[self class] JSONKeyPathsByPropertyKey];
}


+ (NSDictionary *)photoBoxKeyPathsByPropertyKeyWithDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:[PhotoBoxModel JSONKeyPathsByPropertyKey]];
    if (dictionary) [mutableDict addEntriesFromDictionary:dictionary];
    return mutableDict;
}


@end
