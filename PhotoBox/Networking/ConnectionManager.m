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

+ (NSURL *)oAuthInitialUrlForServer:(NSString *)server {
    NSString *callback = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
    NSString *path = [NSString stringWithFormat:@"/v1/oauth/authorize?oauth_callback=%@://&name=", callback];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *fullPath = [[NSString alloc]initWithFormat:@"%@%@%@",server,path,[appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] ;
    
    NSURL *url = [NSURL URLWithString:fullPath];
    return url;
}

+ (NSURL *)oAuthAccessUrlForServer:(NSString *)server {
    NSString* url = [[NSString alloc]initWithFormat:@"%@%@",server,@"/v1/oauth/token/access"];
    return [NSURL URLWithString:url];
}

@end
