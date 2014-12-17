//
//  LocationManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/2/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <AFNetworking.h>
#import <AFHTTPRequestOperation.h>
#import "LocationManager.h"
#import "DLFDatabaseManager.h"
#import <YapDatabase.h>

#define FOURSQUARE_CLIENT_ID @"YE01OOGFTM5L3NDWWWGOVAANYV3QEHVCG421PSNQUBRTXAMS"
#define FOURSQUARE_CLIENT_SECRET @"XEIWU4SHBATNHZBEW0FRMEMVANJKHSZ4SGYMFAMSMVFQZYQ2"
#define FOURSQUARE_API_VERSION_DATE @"20140226"

#define GOOGLE_API_KEY @"AIzaSyBNPVTaMXoa5nxY-Ms_cCrDPra8M27BYt8"

#define LOCATION_CACHE_KEY @"com.getdelightfulapp.location.cache.key"


NSString *const PhotoBoxLocationPlacemarkDidFetchNotification = @"nico.PhotoBoxLocationPlacemarkDidFetchNotification";

@interface LocationManager ()

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSOperationQueue *requestQueue;

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
    self.requestQueue = [[NSOperationQueue alloc] init];
    [self.requestQueue setMaxConcurrentOperationCount:1];
    [self.requestQueue setName:@"ayano.geocoder"];
}

- (BFTask *)nameForLocation:(CLLocation *)location {
    if (!location) {
        return [BFTask taskWithResult:nil];
    }
    __block NSArray *placemarks;
    [[[DLFDatabaseManager manager] readConnection] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        placemarks = [transaction objectForKey:location.description inCollection:locationsCollectionName];
    }];
    if (placemarks) {
        return [BFTask taskWithResult:placemarks];
    }
    
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOperation = blockOperation;
    __weak typeof (self) selfie = self;
    [blockOperation addExecutionBlock:^{
        if ([weakOperation isCancelled]) {
            return;
        }
        [selfie.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                [task setError:error];
            } else {
                [[[DLFDatabaseManager manager] writeConnection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    [transaction setObject:placemarks forKey:location.description inCollection:locationsCollectionName];
                } completionBlock:^{
                    [task setResult:placemarks];
                }];
            }
        }];
    }];
    [self.requestQueue addOperation:blockOperation];
    return task.task;
}

@end
