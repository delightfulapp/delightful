//
//  PhotoBoxClient.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AFOAuth1Client.h"
#import <OVCClient.h>

@class ALAsset;

@class Album;

@class DLFAsset;

typedef NS_ENUM(NSInteger, ResourceType) {
    AlbumResource,
    PhotoResource,
    PhotoWithTagsResource,
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

#pragma mark - Resource Fetch

- (void)getPhotosForPage:(int)page
                    sort:(NSString *)sort
                pageSize:(int)pageSize
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;
- (void)getAlbumsForPage:(int)page
                pageSize:(int)pageSize
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;
- (void)getTagsForPage:(int)page pageSize:(int)pageSize
               success:(void(^)(id object))successBlock
               failure:(void(^)(NSError*))failureBlock;
- (void)getPhotosInAlbum:(NSString *)albumId
                    sort:(NSString *)sort
                    page:(int)page
                pageSize:(int)pageSize
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;
- (void)getPhotosInTag:(NSString *)tagId
                  sort:(NSString *)sort
                  page:(int)page
              pageSize:(int)pageSize
               success:(void(^)(id object))successBlock
               failure:(void(^)(NSError*))failureBlock;


#pragma mark - Sharing

- (void)fetchSharingTokenForPhotoWithId:(NSString *)photoId completionBlock:(void(^)(NSString *token))completion;

#pragma mark - Refresh

- (void)refreshConnectionParameters;

#pragma mark - Upload

- (void)uploadAsset:(DLFAsset *)photo
           progress:(void(^)(float progress))progress
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
