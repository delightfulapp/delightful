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


@end
