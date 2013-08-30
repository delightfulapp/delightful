//
//  ConnectionManager.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionManager : NSObject

+ (ConnectionManager *)sharedManager;

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *consumerKey;
@property (nonatomic, strong) NSString *consumerSecret;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthSecret;

- (void)setBaseURL:(NSURL *)baseURL
       consumerKey:(NSString *)consumerKey
    consumerSecret:(NSString *)consumerSecret
        oauthToken:(NSString *)oauthToken
       oauthSecret:(NSString *)oauthSecret;

@end
