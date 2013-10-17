//
//  UIImage+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIImage+Additionals.h"

@implementation UIImage (Additionals)

- (BOOL)isLandscape {
    if (self.size.width > self.size.height) {
        return YES;
    }
    return NO;
}

@end
