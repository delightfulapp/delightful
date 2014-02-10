//
//  LocationManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/2/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "LocationManager.h"

NSString *const PhotoBoxLocationPlacemarkDidFetchNotification = @"nico.PhotoBoxLocationPlacemarkDidFetchNotification";

@interface LocationManager ()

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation LocationManager

+ (id)sharedManager {
    static LocationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        [_sharedManager setup];
    });
    
    return _sharedManager;
}

- (void)setup {
    _queue = [[NSOperationQueue alloc] init];
    [_queue setMaxConcurrentOperationCount:1];
}

- (void)nameForLocation:(CLLocation*)location completionHandler:(void(^)(NSArray* placemarks, NSError* error))completionHandler {
    if (!self.geocoder)
        self.geocoder = [[CLGeocoder alloc] init];

    __weak typeof (self) selfie = self;
    [self.queue addOperationWithBlock:^{
        [selfie.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (completionHandler) {
                completionHandler(placemarks, error);
            }
        }];
    }];
}


@end
