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
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, strong) NSMutableArray *queues;

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
    [self addObserver:self forKeyPath:@"isFetching" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)nameForLocation:(CLLocation*)location completionHandler:(void(^)(NSArray* placemarks, NSError* error))completionHandler {
    if (!self.geocoder)
        self.geocoder = [[CLGeocoder alloc] init];
    if (!self.queues) {
        self.queues = [NSMutableArray array];
    }
    NSDictionary *dict = @{@"location": location, @"completion":completionHandler};
    [self.queues addObject:dict];
    
    if (self.queues.count == 1) {
        self.isFetching = YES;
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            completionHandler(placemarks, error);
            self.isFetching = NO;
            [self.queues removeObject:dict];
        }];
    }
}

- (void)getNameForLocationInQueue {
    int count = self.queues.count;
    self.isFetching = YES;
    if (count > 0) {
        NSDictionary *dict = [self.queues firstObject];
        [self.queues removeObject:dict];
        CLLocation *location = [dict objectForKey:@"location"];
        void(^completionBlock)(NSArray *, NSError*) = [dict objectForKey:@"completion"];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            completionBlock(placemarks, error);
            self.isFetching = NO;
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    BOOL isFetchingHere = [[change objectForKey:@"new"] boolValue];
    if (!isFetchingHere) {
        [self getNameForLocationInQueue];
    }
}

@end
