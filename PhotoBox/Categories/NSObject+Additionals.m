//
//  NSObject+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/5/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "NSObject+Additionals.h"

#import "NSString+Additionals.h"

#import <objc/runtime.h>

@implementation NSObject (Additionals)

+ (NSString *)propertyTypeStringForPropertyName:(NSString *)propertyName {
    objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
    NSString *attributesString = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    return [attributesString stringBetweenString:@"\"" andString:@"\""];
}

@end
