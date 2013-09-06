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
            _width = [array[1] floatValue];
            _height = [array[2] floatValue];
        }
        
    }
    return self;
}

@end
