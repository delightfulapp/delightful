//
//  ALAsset+Additionals.m
//  Delightful
//
//  Created by Nico Prananta on 6/10/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "ALAsset+Additionals.h"

#import <CoreLocation/CoreLocation.h>

@implementation ALAsset (Additionals)

- (NSString *)latitudeString {
    CLLocation *location = [self valueForProperty:ALAssetPropertyLocation];
    if (!location) {
        return nil;
    }
    return [NSString stringWithFormat:@"%f", location.coordinate.latitude];
}

- (NSString *)longitudeString {
    CLLocation *location = [self valueForProperty:ALAssetPropertyLocation];
    if (!location) {
        return nil;
    }
    return [NSString stringWithFormat:@"%f", location.coordinate.longitude];
}

- (NSData *)defaultRepresentationData {
    Byte *buffer = (Byte*)malloc(self.defaultRepresentation.size);
    NSUInteger buffered = [self.defaultRepresentation getBytes:buffer fromOffset:0.0 length:self.defaultRepresentation.size error:nil];
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    return data;
}

@end
