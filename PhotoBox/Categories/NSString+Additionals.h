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
- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end;
- (NSString *)localizedDate;
- (NSString *)htmlLinkString;

@end
