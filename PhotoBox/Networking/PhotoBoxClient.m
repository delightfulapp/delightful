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

#pragma mark - Setter

- (void)setValue:(id)value forKey:(NSString *)key {
    [super setValue:value forKey:key];
    [self.oauthClient setValue:value forKey:key];
}

#pragma mark - Resource Fetch

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
                if (type == TagResource) [self getTagsWithSuccess:successBlock failure:failureBlock];
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
    [self GET:[NSString stringWithFormat:@"/albums/list.json?page=%d&pageSize=%d",page, pageSize] parameters:nil resultClass:[Album class] resultKeyPath:@"result" completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
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
    
    NSString *album = [NSString stringWithFormat:@"/album-%@", albumId];
    if ([albumId isEqualToString:PBX_allAlbumIdentifier]) album = @"";
    NSString *path = [NSString stringWithFormat:@"/photos%@/list.json?page=%d&pageSize=%d&%@&%@", album, page, pageSize, [self sortByQueryString:@"dateTaken,DESC"], [self photoSizesString]];
    
    [self GET:path parameters:nil resultClass:[Photo class] resultKeyPath:@"result" completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (!error) {
            successBlock(responseObject);
        } else {
            failureBlock(error);
        }
    }];
}

- (void)getTagsWithSuccess:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    [self getPath:@"/tags/list.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock([self processResponseObject:responseObject resourceClass:[Tag class]]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
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
    NSArray *sizes = @[@"200x200",
                       @"640x640"
                       ];
    return AFQueryStringFromParametersWithEncoding(@{@"returnSizes": [sizes componentsJoinedByString:@","]}, NSUTF8StringEncoding);
}

- (NSString *)sortByQueryString:(NSString *)sortBy {
    return AFQueryStringFromParametersWithEncoding(@{@"sortBy": sortBy}, NSUTF8StringEncoding);
}

#pragma mark - Oauth1Client

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    return [self.oauthClient requestWithMethod:method path:path parameters:parameters];
}

- (void)setAccessToken:(AFOAuth1Token *)accessToken {
    [self.oauthClient setAccessToken:accessToken];
}

- (void)acquireOAuthAccessTokenWithPath:(NSString *)path requestToken:(AFOAuth1Token *)requestToken accessMethod:(NSString *)accessMethod success:(void (^)(AFOAuth1Token *, id))success failure:(void (^)(NSError *))failure {
    [self.oauthClient acquireOAuthAccessTokenWithPath:path requestToken:requestToken accessMethod:accessMethod success:success failure:failure];
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
    [operation setContext:[NSManagedObjectContext workContext]];
    return operation;
    
}


@end
