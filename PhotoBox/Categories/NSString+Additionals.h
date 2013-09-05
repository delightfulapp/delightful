//
//  NSString+Additionals.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additionals)

- (BOOL)isValidURL;
- (NSString *)stringWithHttpSchemeAddedIfNeeded;

@end
