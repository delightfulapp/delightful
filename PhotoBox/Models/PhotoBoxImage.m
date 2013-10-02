//
//  Image.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxImage.h"

@implementation PhotoBoxImage

- (id)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        if (array && array.count == 3) {
            _urlString = array[0];
            _width = array[1];
            _height = array[2];
        }
        
    }
    return self;
}

- (NSArray *)toArray {
    return @[self.urlString, self.width, self.height];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super class] photoBoxKeyPathsByPropertyKeyWithDictionary:nil];
}

#pragma mark - Managed Object Serialization

+ (NSString *)managedObjectEntityName {
    return [[self class] photoBoxManagedObjectEntityNameForClassName:NSStringFromClass([self class])];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return [[super class] photoBoxKeyPathsByPropertyKeyWithDictionary:nil];
}

@end
