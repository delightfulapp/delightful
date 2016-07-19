//
//  APIClient.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//


@import Photos;

@class Album;
@class Photo;
@class DLFAsset;
@class AFOAuth1Token;

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


@interface APIClient : NSObject

@property (nonatomic, strong) AFOAuth1Token *consumerToken;
@property (nonatomic, strong) AFOAuth1Token *accessToken;
@property (nonatomic, strong) NSURLSession *session;

+ (APIClient *)sharedClient;

#pragma mark - Resource Fetch

- (NSURLSessionDataTask *)getPhotosForPage:(int)page
                    sort:(NSString *)sort
                pageSize:(int)pageSize
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;

- (NSURLSessionDataTask *)getAlbumsForPage:(int)page
                pageSize:(int)pageSize
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;

- (NSURLSessionDataTask *)getTagsForPage:(int)page pageSize:(int)pageSize
               success:(void(^)(id object))successBlock
               failure:(void(^)(NSError*))failureBlock;

- (NSURLSessionDataTask *)getPhotosInAlbum:(NSString *)albumId
                    sort:(NSString *)sort
                    page:(int)page
                pageSize:(int)pageSize
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;

- (NSURLSessionDataTask *)getPhotosInTag:(NSString *)tagId
                  sort:(NSString *)sort
                  page:(int)page
              pageSize:(int)pageSize
               success:(void(^)(id object))successBlock
               failure:(void(^)(NSError*))failureBlock;

#pragma mark - Favorite

- (NSURLSessionDataTask *)addFavoritePhoto:(Photo *)photo
                             success:(void(^)(id object))successBlock
                             failure:(void(^)(NSError*))failureBlock;
- (NSURLSessionDataTask *)addFavoritePhotoWithId:(NSString *)photoId
                          success:(void(^)(id object))successBlock
                          failure:(void(^)(NSError*))failureBlock;
- (NSURLSessionDataTask *)removeFavoritePhoto:(Photo *)photo
                          success:(void(^)(id object))successBlock
                          failure:(void(^)(NSError*))failureBlock;
- (NSURLSessionDataTask *)removeFavoritePhotoWithId:(NSString *)photo
                             success:(void(^)(id object))successBlock
                             failure:(void(^)(NSError*))failureBlock;

#pragma mark - Album

- (NSURLSessionDataTask *)createNewAlbum:(NSString *)albumName
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

- (void)acquireOAuthAccessTokenWithPath:(NSString *)path
                           requestToken:(AFOAuth1Token *)requestToken
                           accessMethod:(NSString *)accessMethod
                                success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success
                                failure:(void (^)(NSError *error))failure;
@end
