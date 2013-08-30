//
//  ConnectionManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager

+ (ConnectionManager *)sharedManager {
    static ConnectionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (void)setBaseURL:(NSURL *)baseURL consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret oauthToken:(NSString *)oauthToken oauthSecret:(NSString *)oauthSecret {
    self.baseURL = baseURL;
    self.consumerKey = consumerKey;
    self.consumerSecret = consumerSecret;
    self.oauthToken = oauthToken;
    self.oauthSecret = oauthSecret;
}

@end
