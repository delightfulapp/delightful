//
//  PhotoBoxClient.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxClient.h"

#import "ConnectionManager.h"
#import "PhotoBoxRequestOperation.h"

#import "Album.h"
#import "Photo.h"
#import "Tag.h"

#import <objc/runtime.h>

@interface PhotoBoxClient ()

@property (nonatomic, strong) AFOAuth1Client *oauthClient;

- (void)getAlbumsForPage:(int)page
                pageSize:(int)pageSize
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;
- (void)getPhotosInAlbum:(NSString *)albumId
                    page:(int)page
                pageSize:(int)pageSize
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;
- (void)getTagsWithSuccess:(void(^)(id object))successBlock
                   failure:(void(^)(NSError*))failureBlock;
- (void)getAllPhotosOnPage:(int)page
                  pageSize:(int)pageSize success:(void(^)(id object))successBlock
                   failure:(void(^)(NSError*))failureBlock;

@end

@implementation PhotoBoxClient

+ (PhotoBoxClient *)sharedClient {
    static PhotoBoxClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PhotoBoxClient alloc] initWithBaseURL:[[ConnectionManager sharedManager] baseURL] key:[[[ConnectionManager sharedManager] consumerToken] key] secret:[[[ConnectionManager sharedManager] consumerToken] secret]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    _oauthClient = [[AFOAuth1Client alloc] initWithBaseURL:url key:key secret:secret];
    
    if ([[ConnectionManager sharedManager] isUserLoggedIn]) {
        [_oauthClient setAccessToken:[[ConnectionManager sharedManager] oauthToken]];
    }
    [self setParameterEncoding:AFFormURLParameterEncoding];
    [self registerHTTPOperationClass:[PhotoBoxRequestOperation class]];
    
    return self;
}

- (void)refreshConnectionParameters {
    [self setValue:[[ConnectionManager sharedManager] baseURL] forKey:@"baseURL"];
    [self setValue:[[[ConnectionManager sharedManager] consumerToken] key] forKey:@"key"];
    [self setValue:[[[ConnectionManager sharedManager] consumerToken] secret] forKey:@"secret"];
    [self setAccessToken:[[ConnectionManager sharedManager] oauthToken]];
}

#pragma mark - Setter

- (void)setValue:(id)value forKey:(NSString *)key {
    [super setValue:value forKey:key];
    [self.oauthClient setValue:value forKey:key];
}

#pragma mark - Resource Fetch

- (void)fetchSharingTokenForPhotoWithId:(NSString *)photoId completionBlock:(void (^)(NSString *))completion {
    PBX_LOG(@"Fetching sharing token");
    NSString *path = [NSString stringWithFormat: @"/token/photo/%@/create.json", photoId];
    [self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            NSDictionary *result = responseObject[@"result"];
            NSString *token = nil;
            if ([result isKindOfClass:[NSDictionary class]]){
                token = result[@"id"];
            }
            PBX_LOG(@"Fetching sharing token succeed");
            completion(token);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        PBX_LOG(@"Fetching sharing token failed: %@", error);
        completion(nil);
    }];
}

- (void)getResource:(ResourceType)type
             action:(ActionType)action
         resourceId:(NSString *)resourceId
               page:(int)page
            success:(void (^)(id))successBlock
            failure:(void (^)(NSError *))failureBlock {
    [self getResource:type action:action resourceId:resourceId page:page pageSize:20 success:successBlock failure:failureBlock];
}

- (void)getResource:(ResourceType)type action:(ActionType)action resourceId:(NSString *)resourceId page:(int)page pageSize:(int)pageSize success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    if (pageSize==0) pageSize = 20;
    if ([[ConnectionManager sharedManager] isUserLoggedIn]) {
        switch (action) {
            case ListAction:{
                if (type == AlbumResource) [self getAlbumsForPage:page pageSize:pageSize success:successBlock failure:failureBlock];
                else if (type == PhotoResource) [self getPhotosInAlbum:resourceId page:page pageSize:pageSize success:successBlock failure:failureBlock];
                else if (type == TagResource) [self getTagsWithSuccess:successBlock failure:failureBlock];
                else if (type == PhotoWithTagsResource) [self getPhotosInTag:resourceId page:page pageSize:pageSize success:successBlock failure:failureBlock];
                break;
            }
            default:
                break;
        }
    } else {
        [[ConnectionManager sharedManager] openLoginFromStoryboardWithIdentifier:@"loginViewController"];
    }
}

- (void)getAlbumsForPage:(int)page
                pageSize:(int)pageSize
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    [self GET:[NSString stringWithFormat:@"/albums/list.json?page=%d&pageSize=%d&%@",page, pageSize, [self photoSizesString]] parameters:nil resultClass:[Album class] resultKeyPath:@"result" completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (!error) {
            successBlock(responseObject);
        } else {
            failureBlock(error);
        }
    }];
}

- (void)getPhotosInResource:(Class)resourceClass resourceId:(NSString *)resourceId page:(int)page pageSize:(int)pageSize success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    NSString *resource = nil;
    if ([resourceClass isSubclassOfClass:Album.class]) {
        resource = [NSString stringWithFormat:@"&%@", [self albumsQueryString:resourceId]];
    } else if ([resourceClass isSubclassOfClass:Tag.class]) {
        resource = [NSString stringWithFormat:@"&%@", [self tagsQueryString:resourceId]];
    }
    
    NSString *sort = [self sortByQueryString:@"dateTaken,DESC"];
    if ([resourceId isEqualToString:PBX_allAlbumIdentifier]){
        resource = @"";
        sort = [self sortByQueryString:@"dateUploaded,DESC"];
    }
    NSString *path = [NSString stringWithFormat:@"/v2/photos/list.json?page=%d&pageSize=%d&%@&%@%@", page, pageSize, sort, [self photoSizesString], resource];
    [self GET:path parameters:nil resultClass:[Photo class] resultKeyPath:@"result" completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (!error) {
            successBlock(responseObject);
        } else {
            failureBlock(error);
        }
    }];
}

- (void)getPhotosInAlbum:(NSString *)albumId
                    page:(int)page
                pageSize:(int)pageSize
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    [self getPhotosInResource:Album.class resourceId:albumId page:page pageSize:pageSize success:successBlock failure:failureBlock];
}

- (void)getPhotosInTag:(NSString *)tagId
                    page:(int)page
                pageSize:(int)pageSize
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    [self getPhotosInResource:Tag.class resourceId:tagId page:page pageSize:pageSize success:successBlock failure:failureBlock];
}

- (void)getTagsWithSuccess:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    [self GET:@"/tags/list.json" parameters:nil resultClass:[Tag class] resultKeyPath:@"result" completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (!error) {
            successBlock(responseObject);
        } else {
            failureBlock(error);
        }
    }];
}

- (void)getAllPhotosOnPage:(int)page
                  pageSize:(int)pageSize success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    [self getPhotosInAlbum:nil page:page
                  pageSize:(int)pageSize success:successBlock failure:failureBlock];
}

- (NSArray *)processResponseObject:(NSDictionary *)responseObject resourceClass:(Class)resource {
    NSArray *result = [responseObject objectForKey:@"result"];
    NSValueTransformer *transformer = [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:resource];
    return [transformer transformedValue:result];
}

#pragma mark - Getters

NSString *stringForPluralResourceType(ResourceType input) {
    NSArray *arr = @[
                     @"albums",
                     @"photos",
                     @"tags"
                     ];
    return (NSString *)[arr objectAtIndex:input];
}

NSString *stringForSingleResourceType(ResourceType input) {
    NSArray *arr = @[
                     @"albums",
                     @"photos",
                     @"tags"
                     ];
    return (NSString *)[arr objectAtIndex:input];
}

NSString *stringWithActionType(ActionType input) {
    NSArray *arr = @[
                     @"ListAction",
                     @"ViewAction",
                     @"UpdateAction",
                     @"DeleteAction",
                     @"CreateAction"
                     ];
    return (NSString *)[arr objectAtIndex:input];
}

- (NSString *)photoSizesString {
    NSArray *sizes = @[@"320x320",
                       @"640x640"
                       ];
    return AFQueryStringFromParametersWithEncoding(@{@"returnSizes": [sizes componentsJoinedByString:@","]}, NSUTF8StringEncoding);
}

- (NSString *)sortByQueryString:(NSString *)sortBy {
    return AFQueryStringFromParametersWithEncoding(@{@"sortBy": sortBy}, NSUTF8StringEncoding);
}

- (NSString *)albumsQueryString:(NSString *)album {
    return AFQueryStringFromParametersWithEncoding(@{@"album": album}, NSUTF8StringEncoding);
}

- (NSString *)tagsQueryString:(NSString *)tag {
    return AFQueryStringFromParametersWithEncoding(@{@"tags": tag}, NSUTF8StringEncoding);
}

#pragma mark - Oauth1Client

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    return [self.oauthClient requestWithMethod:method path:path parameters:parameters];
}

- (void)acquireOAuthAccessTokenWithPath:(NSString *)path requestToken:(AFOAuth1Token *)requestToken accessMethod:(NSString *)accessMethod success:(void (^)(AFOAuth1Token *, id))success failure:(void (^)(NSError *))failure {
    [self.oauthClient acquireOAuthAccessTokenWithPath:path requestToken:requestToken accessMethod:accessMethod success:success failure:failure];
}

- (void)setAccessToken:(AFOAuth1Token *)accessToken {
    [self.oauthClient setAccessToken:accessToken];
}

- (void)setKey:(NSString *)key {
    [self.oauthClient setValue:key forKey:@"key"];
}

- (void)setSecret:(NSString *)secret {
    [self.oauthClient setValue:secret forKey:@"secret"];
}

#pragma mark - OVCClient

- (PhotoBoxRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest resultClass:(Class)resultClass resultKeyPath:(NSString *)keyPath completion:(void (^)(AFHTTPRequestOperation *, id, NSError *))block {
    PhotoBoxRequestOperation *operation = (PhotoBoxRequestOperation *)[super HTTPRequestOperationWithRequest:urlRequest resultClass:resultClass resultKeyPath:keyPath completion:block];
    [operation setUseCoreData:YES];
    return operation;
    
}


@end
