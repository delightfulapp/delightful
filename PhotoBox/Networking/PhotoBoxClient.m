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
#import "ALAsset+Additionals.h"
#import "DLFAsset.h"

#import <objc/runtime.h>
#import <OVCMultipartPart.h>

@interface AFOAuth1Client ()
- (NSString *)authorizationHeaderForMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters;
@end

@interface PhotoBoxClient ()

@property (nonatomic, strong) AFOAuth1Client *oauthClient;


@end

@implementation PhotoBoxClient

+ (PhotoBoxClient *)sharedClient {
    static PhotoBoxClient *_sharedClient = nil;
    static dispatch_once_t onceTokenn;
    dispatch_once(&onceTokenn, ^{
        _sharedClient = [[PhotoBoxClient alloc] initWithBaseURL:[[ConnectionManager sharedManager] baseURL] key:[[[ConnectionManager sharedManager] consumerToken] key] secret:[[[ConnectionManager sharedManager] consumerToken] secret]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret{
    if (!url) {
        url = [NSURL URLWithString:@"http://trovebox.com"];
    }
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

- (void)loginIfNecessaryToConnect:(void(^)())connectionBlock{
    if ([[ConnectionManager sharedManager] isUserLoggedIn]) {
        connectionBlock();
    } else {
        [[ConnectionManager sharedManager] openLoginFromStoryboardWithIdentifier:@"loginViewController"];
    }
}

#pragma mark - Setter

- (void)setValue:(id)value forKey:(NSString *)key {
    [super setValue:value forKey:key];
    [self.oauthClient setValue:value forKey:key];
}

#pragma mark - Share

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

#pragma mark - Resource Fetch

- (void)getPhotosForPage:(int)page
                    sort:(NSString *)sort
                pageSize:(int)pageSize
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock {
    [self getPhotosInAlbum:nil
                      sort:sort
                      page:page
                  pageSize:(int)pageSize
                   success:successBlock
                   failure:failureBlock];
}

- (void)getAlbumsForPage:(int)page
                pageSize:(int)pageSize
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    [self loginIfNecessaryToConnect:^{
        [self GET:[NSString stringWithFormat:@"v1/albums/list.json?page=%d&pageSize=%d&%@",page, pageSize, [self photoSizesString]] parameters:nil resultClass:[Album class] resultKeyPath:@"result" success:successBlock failure:failureBlock];
    }];
}

- (void)getTagsForPage:(int)page pageSize:(int)pageSize success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    [self loginIfNecessaryToConnect:^{
        [self GET:[NSString stringWithFormat:@"v1/tags/list.json?page=%d&pageSize=%d",page, pageSize] parameters:nil resultClass:[Tag class] resultKeyPath:@"result" success:successBlock failure:failureBlock];
    }];
}

- (void)getPhotosInAlbum:(NSString *)albumId
                    sort:(NSString *)sort
                    page:(int)page
                pageSize:(int)pageSize
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    [self getPhotosInResource:(albumId)?Album.class:Photo.class resourceId:albumId sort:sort page:page pageSize:pageSize success:successBlock failure:failureBlock];
}

- (void)getPhotosInTag:(NSString *)tagId
                  sort:(NSString *)sort
                  page:(int)page
              pageSize:(int)pageSize
               success:(void(^)(id object))successBlock
               failure:(void(^)(NSError*))failureBlock {
    [self getPhotosInResource:Tag.class resourceId:tagId sort:nil page:page pageSize:pageSize success:successBlock failure:failureBlock];
}

- (void)getPhotosInResource:(Class)resourceClass resourceId:(NSString *)resourceId sort:(NSString *)sort page:(int)page pageSize:(int)pageSize success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    NSString *resource = nil;
    if ([resourceClass isSubclassOfClass:Album.class]) {
        resource = [NSString stringWithFormat:@"&%@", [self albumsQueryString:resourceId]];
    } else if ([resourceClass isSubclassOfClass:Tag.class]) {
        resource = [NSString stringWithFormat:@"&%@", [self tagsQueryString:resourceId]];
    }
    
    if (!sort) {
        sort = [self sortByQueryString:@"dateTaken,DESC"];
        if ([resourceId isEqualToString:PBX_allAlbumIdentifier]){
            resource = @"";
            sort = [self sortByQueryString:@"dateUploaded,DESC"];
        }
    } else {
        sort = [self sortByQueryString:sort];
    }
    
    NSString *path = [NSString stringWithFormat:@"/v2/photos/list.json?page=%d&pageSize=%d&%@&%@", page, pageSize, sort, [self photoSizesString]];
    if (resource) {
        path = [path stringByAppendingString:resource];
    }
    
    [self loginIfNecessaryToConnect:^{
        [self GET:path parameters:nil resultClass:[Photo class] resultKeyPath:@"result" success:successBlock failure:failureBlock];
    }];
    
}

- (NSArray *)processResponseObject:(NSDictionary *)responseObject resourceClass:(Class)resource {
    NSArray *result = [responseObject objectForKey:@"result"];
    NSValueTransformer *transformer = [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:resource];
    return [transformer transformedValue:result];
}

- (OVCRequestOperation *)GET:(NSString *)path parameters:(NSDictionary *)parameters resultClass:(Class)resultClass resultKeyPath:(NSString *)keyPath success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    return [self GET:path parameters:parameters resultClass:resultClass resultKeyPath:keyPath completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        PBX_LOG(@"Fetched responses");
        if (!error) {
            successBlock(responseObject);
        } else {
            if (operation.response.statusCode == 401) {
               // [[ConnectionManager sharedManager] logout];
            } else {
                failureBlock(error);
            }

        }
    }];
}

#pragma mark - Post

- (void)uploadAsset:(DLFAsset *)asset
           progress:(void(^)(float progress))progress
            success:(void(^)(id object))successBlock
            failure:(void(^)(NSError*))failureBlock {
    ALAsset *photo = asset.asset;
    if (photo.defaultRepresentation.url) {
        NSString *tags = asset.tags;
        Album *album = asset.album;
        BOOL privatePhotos = asset.privatePhoto;
        
        NSString *type = photo.defaultRepresentation.UTI;
        NSString *fileName = photo.defaultRepresentation.filename;
        NSData *data = [photo defaultRepresentationData];
        NSString *latitude = [photo latitudeString];
        NSString *longitude = [photo longitudeString];
        NSString *path = @"/photo/upload.json";
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if (latitude && longitude) {
            [params addEntriesFromDictionary:@{@"latitude": latitude, @"longitude": longitude}];
        }
        if (tags && tags.length > 0) {
            [params addEntriesFromDictionary:@{@"tags": tags}];
        }
        if (album) {
            [params addEntriesFromDictionary:@{@"albums": album.albumId}];
        }
        [params addEntriesFromDictionary:@{@"permission": (privatePhotos)?@"0":@"1"}];
        
        OVCMultipartPart *part = [OVCMultipartPart partWithData:data name:@"photo" type:type filename:fileName];
        NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:params parts:@[part]];
        [request setValue:[self.oauthClient authorizationHeaderForMethod:request.HTTPMethod path:path parameters:params] forHTTPHeaderField:@"Authorization"];
        [request setHTTPShouldHandleCookies:NO];
        OVCRequestOperation *operation = [self HTTPRequestOperationWithRequest:request resultClass:[Photo class] resultKeyPath:@"result" completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
            if (error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            } else {
                if (successBlock) {
                    successBlock(responseObject);
                }
            }
        }];
        if (progress) {
            [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                float prog = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
                progress(prog);
            }];
        }
        
        [self enqueueHTTPRequestOperation:operation];
    } else {
        if (failureBlock) {
            NSError *error = [NSError errorWithDomain:@"com.getdelightful" code:-100 userInfo:@{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Invalid asset", nil)}];
            failureBlock(error);
        }
    }
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


@end
