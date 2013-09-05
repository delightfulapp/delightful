//
//  ConnectionManager.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFOAuth1Client.h>

@interface ConnectionManager : NSObject

+ (ConnectionManager *)sharedManager;

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) AFOAuth1Token *consumerToken;
@property (nonatomic, strong) AFOAuth1Token *oauthToken;

- (void)setBaseURL:(NSURL *)baseURL
       consumerKey:(NSString *)consumerKey
    consumerSecret:(NSString *)consumerSecret
        oauthToken:(NSString *)oauthToken
       oauthSecret:(NSString *)oauthSecret;

- (BOOL)isUserLoggedIn;
- (void)startOAuthAuthorizationWithServerURL:(NSString *)serverStringURL;
- (void)openLoginFromStoryboardWithIdentifier:(NSString *)storyboardId;

+ (NSURL *)oAuthInitialUrlForServer:(NSString *)server;
+ (NSURL *)oAuthAccessUrlForServer:(NSString *)server;

@end
