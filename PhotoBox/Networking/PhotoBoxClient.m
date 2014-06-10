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

#import <objc/runtime.h>
#import <OVCMultipartPart.h>

@interface AFOAuth1Client ()
- (NSString *)authorizationHeaderForMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters;
@end

@interface PhotoBoxClient ()

@property (nonatomic, strong) AFOAuth1Client *oauthClient;

- (void)getAlbumsForPage:(int)page
                pageSize:(int)pageSize
               fetchedIn:(NSString *)fetchedIn
             mainContext:(NSManagedObjectContext *)mainContext
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;
- (void)getPhotosInAlbum:(NSString *)albumId
                    page:(int)page
                pageSize:(int)pageSize
               fetchedIn:(NSString *)fetchedIn
             mainContext:(NSManagedObjectContext *)mainContext
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock;
- (void)getTagsWithMainContext:(NSManagedObjectContext *)mainContext
                     fetchedIn:(NSString *)fetchedIn
                       success:(void(^)(id object))successBlock
                   failure:(void(^)(NSError*))failureBlock;

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
    [self getResource:type action:action resourceId:resourceId fetchedIn:nil page:page pageSize:20 mainContext:nil success:successBlock failure:failureBlock];
}

- (void)getResource:(ResourceType)type
             action:(ActionType)action
         resourceId:(NSString *)resourceId
          fetchedIn:(NSString *)fetchedIn
               page:(int)page
           pageSize:(int)pageSize
        mainContext:(NSManagedObjectContext *)context
            success:(void (^)(id))successBlock
            failure:(void (^)(NSError *))failureBlock {
    if (pageSize==0) pageSize = 30;
    if ([[ConnectionManager sharedManager] isUserLoggedIn]) {
        switch (action) {
            case ListAction:{
                if (type == AlbumResource) [self getAlbumsForPage:page pageSize:pageSize fetchedIn:fetchedIn mainContext:context success:successBlock failure:failureBlock];
                else if (type == PhotoResource) [self getPhotosInAlbum:resourceId page:page pageSize:pageSize fetchedIn:fetchedIn mainContext:context success:successBlock failure:failureBlock];
                else if (type == TagResource) [self getTagsWithMainContext:context fetchedIn:fetchedIn success:successBlock failure:failureBlock];
                else if (type == PhotoWithTagsResource) [self getPhotosInTag:resourceId page:page pageSize:pageSize fetchedIn:fetchedIn mainContext:context success:successBlock failure:failureBlock];
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
               fetchedIn:(NSString *)fetchedIn
             mainContext:(NSManagedObjectContext *)mainContext
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    [self GET:[NSString stringWithFormat:@"/albums/list.json?page=%d&pageSize=%d&%@",page, pageSize, [self photoSizesString]] parameters:nil resultClass:[Album class] resultKeyPath:@"result" fetchedIn:fetchedIn mainContext:mainContext success:successBlock failure:failureBlock];
}

- (void)getPhotosInAlbum:(NSString *)albumId
                    page:(int)page
                pageSize:(int)pageSize
               fetchedIn:(NSString *)fetchedIn
             mainContext:(NSManagedObjectContext *)mainContext
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    [self getPhotosInResource:Album.class resourceId:albumId page:page pageSize:pageSize fetchedIn:fetchedIn mainContext:mainContext success:successBlock failure:failureBlock];
}

- (void)getPhotosInResource:(Class)resourceClass resourceId:(NSString *)resourceId page:(int)page pageSize:(int)pageSize fetchedIn:(NSString *)fetchedIn mainContext:(NSManagedObjectContext *)mainContext success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
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
    
    [self GET:path parameters:nil resultClass:[Photo class] resultKeyPath:@"result" fetchedIn:fetchedIn mainContext:mainContext success:successBlock failure:failureBlock];
}

- (void)getPhotosInTag:(NSString *)tagId
                    page:(int)page
              pageSize:(int)pageSize fetchedIn:(NSString *)fetchedIn
           mainContext:(NSManagedObjectContext *)mainContext
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    [self getPhotosInResource:Tag.class resourceId:tagId page:page pageSize:pageSize fetchedIn:fetchedIn mainContext:mainContext success:successBlock failure:failureBlock];
}

- (void)getTagsWithMainContext:(NSManagedObjectContext *)mainContext fetchedIn:(NSString *)fetchedIn success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    [self GET:@"/tags/list.json" parameters:nil resultClass:[Tag class] resultKeyPath:@"result" fetchedIn:fetchedIn mainContext:mainContext success:successBlock failure:failureBlock];
}

- (void)getAllPhotosOnPage:(int)page
                  pageSize:(int)pageSize fetchedIn:(NSString *)fetchedIn mainContext:(NSManagedObjectContext *)mainContext success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    [self getPhotosInAlbum:nil page:page
                  pageSize:(int)pageSize fetchedIn:fetchedIn mainContext:mainContext success:successBlock failure:failureBlock];
}

- (NSArray *)processResponseObject:(NSDictionary *)responseObject resourceClass:(Class)resource {
    NSArray *result = [responseObject objectForKey:@"result"];
    NSValueTransformer *transformer = [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:resource];
    return [transformer transformedValue:result];
}

- (OVCRequestOperation *)GET:(NSString *)path parameters:(NSDictionary *)parameters resultClass:(Class)resultClass resultKeyPath:(NSString *)keyPath fetchedIn:(NSString *)fetchedIn mainContext:(NSManagedObjectContext *)mainContext success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    return [self GET:path parameters:parameters resultClass:resultClass resultKeyPath:keyPath completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        PBX_LOG(@"Fetched responses");
        if (!error) {
            successBlock(responseObject);
        } else {
            if (operation.response.statusCode == 401) {
                [[ConnectionManager sharedManager] logout];
            } else {
                failureBlock(error);
            }

        }
    }];
}

#pragma mark - Post

- (void)uploadPhoto:(ALAsset *)photo progress:(void (^)(float))progress success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    if (photo.defaultRepresentation.url) {
        NSString *type = photo.defaultRepresentation.UTI;
        NSString *fileName = photo.defaultRepresentation.filename;
        NSData *data = [photo defaultRepresentationData];
        NSString *latitude = [photo latitudeString];
        NSString *longitude = [photo longitudeString];
        NSString *path = @"/photo/upload.json";
        NSDictionary *params = nil;
        if (latitude && longitude) {
            params = @{@"latitude": latitude, @"longitude": longitude};
        }
        
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
