//
//  PhotoBoxModel.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxModel.h"
#import "NSObject+setValuesForKeysWithJSONDictionary.h"

@implementation PhotoBoxModel

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _rawDictionary = dictionary;
        [self xx_setValuesForKeysWithJSONDictionary:dictionary];
    }
    return self;
}

@end
