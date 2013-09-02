//
//  LocationManager.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/2/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const PhotoBoxLocationPlacemarkDidFetchNotification;

#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

+ (id)sharedManager;

- (void)nameForLocation:(CLLocation*)location completionHandler:(void(^)(NSArray* placemarks, NSError* error))completionHandler;

@end
