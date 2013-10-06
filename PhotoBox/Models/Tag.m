//
//  Tag.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "Tag.h"

@implementation Tag

- (NSString *)itemId {
    return self.tagId;
}

- (id)initWithItemId:(NSString *)tagId {
    self = [super init];
    if (self) {
        _tagId = tagId;
    }
    return self;
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super class] photoBoxKeyPathsByPropertyKeyWithDictionary:@{@"tagId": @"id"}];
}

#pragma mark - Managed object serialization

+ (NSString *)managedObjectEntityName {
    return [[self class] photoBoxManagedObjectEntityNameForClassName:NSStringFromClass([self class])];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return [[super class] photoBoxKeyPathsByPropertyKeyWithDictionary:nil];
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"tagId"];
}


@end
