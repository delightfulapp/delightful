//
//  PhotoBoxClient.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AFOAuth1Client.h"

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


@interface PhotoBoxClient : AFOAuth1Client

+ (PhotoBoxClient *)sharedClient;

- (void)getResource:(ResourceType)type
             action:(ActionType)action
         resourceId:(NSString *)resourceId
               page:(int)page
            success:(void(^)(id object))successBlock
            failure:(void(^)(NSError*))failureBlock;

- (void)getAlbumsForPage:(int)page
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;
- (void)getPhotosInAlbum:(NSString *)albumId page:(int)page
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;
- (void)getTagsWithSuccess:(void(^)(id object))successBlock
                   failure:(void(^)(NSError*))failureBlock;
- (void)getAllPhotosOnPage:(int)page success:(void(^)(id object))successBlock
                         failure:(void(^)(NSError*))failureBlock;
@end
