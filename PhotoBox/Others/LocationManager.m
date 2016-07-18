//
//  LocationManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/2/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AFNetworking.h"
#import "LocationManager.h"
#import "DLFDatabaseManager.h"
#import "YapDatabase.h"

#define FOURSQUARE_CLIENT_ID @"YE01OOGFTM5L3NDWWWGOVAANYV3QEHVCG421PSNQUBRTXAMS"
#define FOURSQUARE_CLIENT_SECRET @"XEIWU4SHBATNHZBEW0FRMEMVANJKHSZ4SGYMFAMSMVFQZYQ2"
#define FOURSQUARE_API_VERSION_DATE @"20140226"

#define GOOGLE_API_KEY @"AIzaSyBNPVTaMXoa5nxY-Ms_cCrDPra8M27BYt8"

#define LOCATION_CACHE_KEY @"com.getdelightfulapp.location.cache.key"


NSString *const PhotoBoxLocationPlacemarkDidFetchNotification = @"nico.PhotoBoxLocationPlacemarkDidFetchNotification";

@interface LocationManager ()

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) BFTask *requestTask;

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
    self.geocoder = [[CLGeocoder alloc] init];
}

- (BFTask *)nameForLocation:(CLLocation *)location {
    if (!location) {
        return [BFTask taskWithResult:nil];
    }
    NSString *key = [NSString stringWithFormat:@"%f-%f", location.coordinate.latitude, location.coordinate.longitude];
    __block NSArray *placemarks;
    [[[DLFDatabaseManager manager] readConnection] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        placemarks = [transaction objectForKey:key inCollection:locationsCollectionName];
    }];
    if (placemarks) {
        return [BFTask taskWithResult:placemarks];
    }
    
    if (!self.requestTask) {
        self.requestTask = [BFTask taskWithResult:nil];
    }
    
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    
    self.requestTask = [self.requestTask continueWithBlock:^id(BFTask *t) {
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                [task setError:error];
            } else {
                if (placemarks && placemarks.count > 0) {
                    [[[DLFDatabaseManager manager] writeConnection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                        [transaction setObject:placemarks forKey:key inCollection:locationsCollectionName];
                    } completionBlock:^{
                        [task setResult:placemarks];
                    }];
                } else {
                    [task setResult:nil];
                }
            }
        }];
        return task.task;
    }];
    
    return task.task;
}

@end
