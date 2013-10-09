//
//  PhotoBoxClient.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AFOAuth1Client.h"
#import <OVCClient.h>

typedef NS_ENUM(NSInteger, ResourceType) {
    AlbumResource,
    PhotoResource,
    TagResource
};

typedef NS_ENUM(NSInteger, ActionType) {
    ListAction,
    ViewAction,
    UpdateAction,
    DeleteAction,
    CreateAction
};


@interface PhotoBoxClient : OVCClient

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *secret;

+ (PhotoBoxClient *)sharedClient;

- (void)getResource:(ResourceType)type
             action:(ActionType)action
         resourceId:(NSString *)resourceId
               page:(int)page
            success:(void(^)(id object))successBlock
            failure:(void(^)(NSError*))failureBlock;

- (void)getResource:(ResourceType)type
             action:(ActionType)action
         resourceId:(NSString *)resourceId
               page:(int)page
           pageSize:(int)pageSize
            success:(void(^)(id object))successBlock
            failure:(void(^)(NSError*))failureBlock;

#pragma mark - Oauth1Client interfaces

- (void)setAccessToken:(AFOAuth1Token *)accessToken;
- (void)acquireOAuthAccessTokenWithPath:(NSString *)path
                           requestToken:(AFOAuth1Token *)requestToken
                           accessMethod:(NSString *)accessMethod
                                success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success
                                failure:(void (^)(NSError *error))failure;
@end
