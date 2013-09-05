//
//  ConnectionManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "ConnectionManager.h"
#import <AFOAuth1Client.h>

NSString *baseURLUserDefaultKey = @"photobox.base.url";
NSString *consumerTokenIdentifier = @"photobox.consumer.token";
NSString *oauthTokenIdentifier = @"photobox.oauth.token";

@implementation ConnectionManager

+ (ConnectionManager *)sharedManager {
    static ConnectionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        AFOAuth1Token *consumerToken = [AFOAuth1Token retrieveCredentialWithIdentifier:consumerTokenIdentifier];
        if (consumerToken) {
            self.consumerToken = consumerToken;
        }
        AFOAuth1Token *oauthToken = [AFOAuth1Token retrieveCredentialWithIdentifier:oauthTokenIdentifier];
        if (oauthToken) {
            self.oauthToken = oauthToken;
        }
        NSURL *baseURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:baseURLUserDefaultKey]];
        if (baseURL) {
            self.baseURL = baseURL;
        }
    }
    return self;
}

- (void)setBaseURL:(NSURL *)baseURL consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret oauthToken:(NSString *)oauthToken oauthSecret:(NSString *)oauthSecret {
    self.baseURL = baseURL;
    if (consumerKey && consumerSecret) {
        self.consumerToken = [[AFOAuth1Token alloc] initWithKey:consumerKey secret:consumerSecret session:nil expiration:nil renewable:YES];
    }
    if (oauthToken && oauthSecret) {
        self.oauthToken = [[AFOAuth1Token alloc] initWithKey:oauthToken secret:oauthSecret session:nil expiration:nil renewable:YES];
    }
}

- (void)setBaseURL:(NSURL *)baseURL {
    if (_baseURL != baseURL) {
        _baseURL = baseURL;
        [[NSUserDefaults standardUserDefaults] setObject:_baseURL.absoluteString forKey:baseURLUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setConsumerToken:(AFOAuth1Token *)consumerToken {
    if (_consumerToken != consumerToken) {
        _consumerToken = consumerToken;
        [AFOAuth1Token storeCredential:_consumerToken withIdentifier:consumerTokenIdentifier];
    }
}

- (void)setOauthToken:(AFOAuth1Token *)oauthToken {
    if (_oauthToken != oauthToken) {
        _oauthToken = oauthToken;
        [AFOAuth1Token storeCredential:_oauthToken withIdentifier:oauthTokenIdentifier];
    }
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
