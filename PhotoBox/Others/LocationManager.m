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

#define FOURSQUARE_CLIENT_ID @"YE01OOGFTM5L3NDWWWGOVAANYV3QEHVCG421PSNQUBRTXAMS"
#define FOURSQUARE_CLIENT_SECRET @"XEIWU4SHBATNHZBEW0FRMEMVANJKHSZ4SGYMFAMSMVFQZYQ2"
#define FOURSQUARE_API_VERSION_DATE @"20140226"

#define GOOGLE_API_KEY @"AIzaSyBNPVTaMXoa5nxY-Ms_cCrDPra8M27BYt8"

#define LOCATION_CACHE_KEY @"com.getdelightfulapp.location.cache.key"

NSString *const PhotoBoxLocationPlacemarkDidFetchNotification = @"nico.PhotoBoxLocationPlacemarkDidFetchNotification";

@interface LocationManager ()

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *locationCache;

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
    
    _locationCache = [[NSMutableDictionary alloc] init];
}

- (void)nameForLocation:(CLLocation*)location completionHandler:(void(^)(NSString* placemark, NSError* error))completionHandler {
    NSString *lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *longi = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    NSString *locationKey = [NSString stringWithFormat:@"%@,%@", lat,longi];
    
    NSString *cachedName = [self.locationCache objectForKey:locationKey];
    NSString *cachedNameFromDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", LOCATION_CACHE_KEY, locationKey]];
    
    if (cachedName) {
        if (completionHandler) {
            completionHandler(cachedName, nil);
        }
        return;
    } else if (cachedNameFromDefaults) {
        if (completionHandler) {
            completionHandler(cachedNameFromDefaults, nil);
        }
        return;
    }
    
    __weak typeof (self) selfie = self;
    
    //NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&ll=%@,%@&v=%@&limit=1", FOURSQUARE_CLIENT_ID, FOURSQUARE_CLIENT_SECRET, lat, longi, FOURSQUARE_API_VERSION_DATE];
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%@&sensor=true&key=%@&result_type=locality", locationKey, GOOGLE_API_KEY];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (!error) {
            if (completionHandler) {
                NSArray *results = [dict objectForKey:@"results"];
                
                if (results && results.count > 0) {
                    NSDictionary *venue = [results firstObject];
                    NSString *location = [venue objectForKey:@"formatted_address"];
                    if (location) {
                        [selfie cacheLocation:locationKey name:location];
                        completionHandler(location, nil);
                    }
                } else {
                    completionHandler(nil, nil);
                }
                /*
                NSArray *unsortedVenues = dict[@"response"][@"venues"];
                NSArray *sort = @[[NSSortDescriptor sortDescriptorWithKey:@"stats.checkinsCount" ascending:NO]];
                NSArray *sorted = [unsortedVenues sortedArrayUsingDescriptors:sort];
                
                NSArray *venues;
                if (sorted) {
                    venues = sorted;
                } else venues = unsortedVenues;
                PBX_LOG(@"%@", venues);
                if (venues && venues.count > 0) {
                    NSDictionary *venue = [venues firstObject];
                    
                    NSString *name = [venue objectForKey:@"name"];
                    NSString *country;
                    NSString *crossStreet;
                    NSString *city;
                    
                    NSDictionary *locationDictionary = [venue objectForKey:@"location"];
                    if (locationDictionary) {
                        country = [locationDictionary objectForKey:@"country"];
                        crossStreet = [locationDictionary objectForKey:@"crossStreet"];
                        city = [locationDictionary objectForKey:@"city"];
                    }
                    
                    NSString *location;
                    
                    if (crossStreet && crossStreet.length > 0) {
                        location = crossStreet;
                        if (country && country.length > 0) {
                            location = [NSString stringWithFormat:@"%@, %@", location, country];
                        }
                    } else {
                        if (name && name.length > 0) {
                            location = name;
                            if (country && country.length > 0) {
                                location = [NSString stringWithFormat:@"%@, %@", location, country];
                            }
                        } else {
                            if (country && country.length > 0) {
                                location = country;
                            }
                        }
                    }
                    
                    
                    if (location && location.length > 0) {
                        [selfie.locationCache setObject:location forKey:locationKey];
                        completionHandler(location, nil);
                    } else {
                        completionHandler(nil, nil);
                    }
                } else {
                    if (completionHandler) {
                        completionHandler(nil,nil);
                    }
                }
                 */
            }
        } else {
            if (completionHandler) {
                completionHandler(nil, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        PBX_LOG(@"Error: %@", error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
    
//    if (!self.geocoder)
//        self.geocoder = [[CLGeocoder alloc] init];
//    
//    if ([self.locationCache objectForKey:location]) {
//        if (completionHandler) {
//            completionHandler(self.locationCache[location], nil);
//            return;
//        }
//    }
//    
//    __weak typeof (self) selfie = self;
//    [self.queue addOperationWithBlock:^{
//        [selfie.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//            [selfie.locationCache setObject:placemarks forKey:location];
//            if (completionHandler) {
//                completionHandler(placemarks, error);
//            }
//        }];
//    }];
}

- (void)cacheLocation:(NSString *)locationKey name:(NSString *)name {
    [self.locationCache setObject:name forKey:locationKey];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:[NSString stringWithFormat:@"%@-%@", LOCATION_CACHE_KEY, locationKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
