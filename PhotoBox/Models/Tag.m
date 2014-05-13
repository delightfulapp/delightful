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
    return [[super class] photoBoxJSONKeyPathsByPropertyKeyWithDictionary:@{@"tagId": @"id"}];
}

@end
