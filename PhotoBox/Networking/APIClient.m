//
//  APIClient.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "APIClient.h"

#import "ConnectionManager.h"
#import "FavoritesManager.h"
#import "Album.h"
#import "Photo.h"
#import "Tag.h"
#import "DLFAsset.h"
#import "AFOAuth1Client.h"
#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>
#import "NSDictionary+MTLManipulationAdditions.h"
#import "TDOauth.h"

@interface APIClient () <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableDictionary *uploadProgressDictionary;

- (NSURLSessionDataTask *)getPhotosInResource:(Class)resourceClass
                          resourceId:(NSString *)resourceId
                                sort:(NSString *)sort
                                page:(int)page
                            pageSize:(int)pageSize
                             success:(void (^)(id))successBlock
                             failure:(void (^)(NSError *))failureBlock;

- (NSURL *)baseURL;

@end

@implementation APIClient

+ (APIClient *)sharedClient {
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceTokenn;
    dispatch_once(&onceTokenn, ^{
        _sharedClient = [[APIClient alloc] init];
    });
    
    return _sharedClient;
}

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        self.uploadProgressDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)refreshConnectionParameters {
    [self setValue:[[[ConnectionManager sharedManager] consumerToken] key] forKey:@"key"];
    [self setValue:[[[ConnectionManager sharedManager] consumerToken] secret] forKey:@"secret"];
    [self setAccessToken:[[ConnectionManager sharedManager] oauthToken]];
}


- (BOOL)isLoggedIn {
    return [[ConnectionManager sharedManager] isUserLoggedIn];
}

- (void)loginIfNecessaryToConnect:(void(^)())connectionBlock{
    if ([self isLoggedIn]) {
        connectionBlock();
    } else {
        [[ConnectionManager sharedManager] openLoginFromStoryboardWithIdentifier:@"loginViewController"];
    }
}

#pragma mark - Favorite

- (NSURLSessionDataTask *)addFavoritePhoto:(Photo *)photo success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    return [self addFavoritePhotoWithId:photo.photoId success:successBlock failure:failureBlock];
}

- (NSURLSessionDataTask *)addFavoritePhotoWithId:(NSString *)photoId success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    NSString *path = [NSString stringWithFormat:@"/photo/%@/update.json", photoId];
    
    return [self POST:path
           parameters:@{@"tagsAdd": favoritesTagName}
          resultClass:[Photo class]
        resultKeyPath:@"result"
              success:successBlock
              failure:failureBlock];
}

- (NSURLSessionDataTask *)removeFavoritePhoto:(Photo *)photo success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    return [self removeFavoritePhotoWithId:photo.photoId success:successBlock failure:failureBlock];
}

- (NSURLSessionDataTask *)removeFavoritePhotoWithId:(NSString *)photo success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    NSString *path = [NSString stringWithFormat:@"/photo/%@/update.json", photo];
    
    return [self POST:path
           parameters:@{@"tagsRemove": favoritesTagName}
          resultClass:[Photo class]
        resultKeyPath:@"result"
              success:successBlock
              failure:failureBlock];
}

#pragma mark - Share

- (void)fetchSharingTokenForPhotoWithId:(NSString *)photoId completionBlock:(void (^)(NSString *))completion {
    //CLS_LOG(@"Fetching sharing token");
    NSString *path = [NSString stringWithFormat: @"/token/photo/%@/create.json", photoId];
    
    [self POST:path
    parameters:nil
   resultClass:[Photo class]
 resultKeyPath:@"result"
       success:^(id responseObject) {
           if (responseObject) {
               NSDictionary *result = responseObject[@"result"];
               NSString *token = nil;
               if ([result isKindOfClass:[NSDictionary class]]){
                   token = result[@"id"];
               }
               completion(token);
           }
       }
       failure:^(NSError *error) {
              completion(nil);
    }];
}

#pragma mark - Resource Fetch

- (NSURLSessionDataTask *)getPhotosForPage:(int)page
                    sort:(NSString *)sort
                pageSize:(int)pageSize
                 success:(void(^)(id object))successBlock
                 failure:(void(^)(NSError*))failureBlock {
    return [self getPhotosInAlbum:nil
                      sort:sort
                      page:page
                  pageSize:(int)pageSize
                   success:successBlock
                   failure:failureBlock];
}

- (NSURLSessionDataTask *)getAlbumsForPage:(int)page
                pageSize:(int)pageSize
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    __block NSURLSessionDataTask *dataTask;
    [self loginIfNecessaryToConnect:^{
        NSDictionary *dict = @{@"page": @(page), @"pageSize": @(pageSize)};
        dict = [dict mtl_dictionaryByAddingEntriesFromDictionary:[self photoSizesDictionary]];
        dataTask = [self GET:@"/v1/albums/list.json" parameters:dict resultClass:[Album class] resultKeyPath:@"result" success:successBlock failure:failureBlock];
    }];
    return dataTask;
}

- (NSURLSessionDataTask *)getTagsForPage:(int)page pageSize:(int)pageSize success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    __block NSURLSessionDataTask *dataTask;
    [self loginIfNecessaryToConnect:^{
        NSDictionary *dict = @{@"page": @(page), @"pageSize": @(pageSize)};
        dataTask = [self GET:@"/v1/tags/list.json" parameters:dict resultClass:[Tag class] resultKeyPath:@"result" success:successBlock failure:failureBlock];
    }];
    return dataTask;
}

- (NSURLSessionDataTask *)getPhotosInAlbum:(NSString *)albumId
                    sort:(NSString *)sort
                    page:(int)page
                pageSize:(int)pageSize
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    return [self getPhotosInResource:((albumId)?Album.class:Photo.class)
                          resourceId:albumId
                                sort:sort
                                page:page
                            pageSize:pageSize
                             success:successBlock
                             failure:failureBlock];
}

- (NSURLSessionDataTask *)getPhotosInTag:(NSString *)tagId
                  sort:(NSString *)sort
                  page:(int)page
              pageSize:(int)pageSize
               success:(void(^)(id object))successBlock
               failure:(void(^)(NSError*))failureBlock {
    return [self getPhotosInResource:Tag.class
                          resourceId:tagId
                                sort:sort
                                page:page
                            pageSize:pageSize
                             success:successBlock
                             failure:failureBlock];
}

- (NSURLSessionDataTask *)getPhotosInResource:(Class)resourceClass
                          resourceId:(NSString *)resourceId
                                sort:(NSString *)sort
                                page:(int)page
                            pageSize:(int)pageSize
                             success:(void (^)(id))successBlock
                             failure:(void (^)(NSError *))failureBlock {
    NSDictionary *resource = nil;
    if ([resourceClass isSubclassOfClass:Album.class]) {
        resource = [self albumsQueryDictionary:resourceId];
    } else if ([resourceClass isSubclassOfClass:Tag.class]) {
        resource = [self tagsQueryDictionary:resourceId];
    }
    
    if (!sort) {
        sort = @"dateTaken,DESC";
        if ([resourceId isEqualToString:PBX_allAlbumIdentifier]){
            resource = nil;
            sort = @"dateUploaded,DESC";
        }
    }
    
    NSString *path = @"/v2/photos/list.json";
    NSDictionary *photoSizes = [self photoSizesDictionary];
    NSDictionary *parameters = @{
                                 @"page": @(page),
                                 @"pageSize": @(pageSize),
                                 @"sortBy": sort,
                                 [photoSizes.allKeys firstObject]: photoSizes[[photoSizes.allKeys firstObject]]
                                 };
    if (resource) {
        parameters = [parameters mtl_dictionaryByAddingEntriesFromDictionary:resource];
    }
    
    __block NSURLSessionDataTask *dataTask;
    [self loginIfNecessaryToConnect:^{
        dataTask = [self GET:path
                  parameters:parameters
                 resultClass:[Photo class]
               resultKeyPath:@"result"
                     success:successBlock
                     failure:failureBlock];
    }];
    
    return dataTask;
}

- (NSURLSessionDataTask *)createNewAlbum:(NSString *)albumName
                                 success:(void(^)(id object))successBlock
                                 failure:(void(^)(NSError*))failureBlock {
    return [self POST:@"/v1/album/create.json" parameters:@{@"name": albumName} resultClass:[Album class] resultKeyPath:@"result" success:successBlock failure:failureBlock];
}

- (NSArray *)processResponseObject:(NSDictionary *)responseObject resourceClass:(Class)resource {
    id result = [responseObject objectForKey:@"result"];
    NSValueTransformer *transformer;
    if ([result isKindOfClass:[NSArray class]]) {
        transformer = [MTLJSONAdapter arrayTransformerWithModelClass:resource];
    } else if ([result isKindOfClass:[NSDictionary class]]) {
        transformer = [MTLJSONAdapter dictionaryTransformerWithModelClass:resource];
    }
    
    return [transformer transformedValue:result];
}

- (NSURLSessionDataTask *)POST:(NSString *)path
                   parameters:(NSDictionary *)parameters
                  resultClass:(Class)resultClass
                resultKeyPath:(NSString *)keyPath
                      success:(void (^)(id))successBlock
                      failure:(void (^)(NSError *))failureBlock {
    NSString *host = [[self baseURL] host];
    NSString *scheme = [[self baseURL] scheme];;
    NSURLRequest *request = [TDOAuth URLRequestForPath:path
                                            parameters:parameters
                                                  host:host
                                           consumerKey:self.consumerToken.key
                                        consumerSecret:self.consumerToken.secret
                                           accessToken:self.accessToken.key
                                           tokenSecret:self.accessToken.secret
                                                scheme:scheme
                                         requestMethod:@"POST"
                                          dataEncoding:TDOAuthContentTypeUrlEncodedForm
                                          headerValues:nil
                                       signatureMethod:TDOAuthSignatureMethodHmacSha1];
    
    
    NSURLSessionDataTask * dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failureBlock(error);
        } else {
            NSError *jsonError = nil;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            id object = [self processResponseObject:dictionary resourceClass:resultClass];
            successBlock(object);
        }
    }];
    
    
    [dataTask resume];
    
    return dataTask;
}

- (NSURLSessionDataTask *)GET:(NSString *)path
                   parameters:(NSDictionary *)parameters
                  resultClass:(Class)resultClass
                resultKeyPath:(NSString *)keyPath
                      success:(void (^)(id))successBlock
                      failure:(void (^)(NSError *))failureBlock {
    
    void (^handleError)(int, NSError *) = ^void(int statusCode, NSError *error) {
        if (statusCode == 401) {
            [[ConnectionManager sharedManager] setIsGuestUser:YES];
        } else {
            failureBlock(error);
            return;
        }
        if ([[ConnectionManager sharedManager] isGuestUser]) {
            NSDictionary *userInfo = error.userInfo;
            if (userInfo) {
                NSString *responseString = userInfo[NSLocalizedRecoverySuggestionErrorKey];
                if (responseString) {
                    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    if (responseObject) {
                        NSArray *results = responseObject[@"result"];
                        if (results) {
                            NSMutableArray *responseObjects = [NSMutableArray arrayWithCapacity:results.count];
                            for (NSDictionary *obj in results) {
                                NSError *error;
                                id transformedObj = [MTLJSONAdapter modelOfClass:resultClass fromJSONDictionary:obj error:&error];
                                if (transformedObj) {
                                    [responseObjects addObject:transformedObj];
                                }
                            }
                            if (successBlock) {
                                successBlock(responseObjects);
                                return;
                            }
                        }
                    }
                }
            }
        }
    };

    NSString *host = [[self baseURL] host];
    NSURLRequest *request = [TDOAuth URLRequestForPath:path
                                         GETParameters:parameters
                                                  host:host
                                           consumerKey:self.consumerToken.key
                                        consumerSecret:self.consumerToken.secret
                                           accessToken:self.accessToken.key
                                           tokenSecret:self.accessToken.secret];
    
    NSURLSessionDataTask * dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            handleError((int)[(NSHTTPURLResponse *)response statusCode], error);
        } else {
            NSError *jsonError = nil;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            successBlock([self processResponseObject:dictionary resourceClass:resultClass]);
        }
    }];
    
    [dataTask resume];

    return dataTask;
}

#pragma mark - Post

- (void)uploadAsset:(DLFAsset *)asset
           progress:(void(^)(float progress))progress
            success:(void(^)(id object))successBlock
            failure:(void(^)(NSError*))failureBlock {
    PHAsset *photo = asset.asset;
    [photo requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
        NSString *tags = asset.tags;
        NSString *smartTags = [asset.smartTags componentsJoinedByString:@","];
        if (smartTags && smartTags.length > 0) {
            if (!tags) {
                tags = @"";
            }
            tags = [[tags stringByAppendingFormat:@", %@", smartTags] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
        }
        Album *album = asset.album;
        BOOL privatePhotos = asset.privatePhoto;
        NSString *fileName = contentEditingInput.fullSizeImageURL.lastPathComponent;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        [options setResizeMode:PHImageRequestOptionsResizeModeNone];
        [options setDeliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat];
        [[PHImageManager defaultManager] requestImageDataForAsset:photo options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            CLLocation *location = photo.location;
            NSString *path = @"/photo/upload.json";
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] forKey:@"photo"];
            if (location) {
                [params addEntriesFromDictionary:@{@"latitude": [NSString stringWithFormat:@"%f", location.coordinate.latitude], @"longitude": [NSString stringWithFormat:@"%f", location.coordinate.longitude]}];
            }
            if (tags && tags.length > 0) {
                [params addEntriesFromDictionary:@{@"tags": tags}];
            }
            if (album) {
                [params addEntriesFromDictionary:@{@"albums": album.albumId}];
            }
            [params addEntriesFromDictionary:@{@"permission": (privatePhotos)?@"0":@"1"}];
            if (asset.photoTitle) {
                [params addEntriesFromDictionary:@{@"title":asset.photoTitle}];
            }
            if (asset.photoDescription) {
                [params addEntriesFromDictionary:@{@"description":asset.photoDescription}];
            }
            
            NSString *host = [[self baseURL] host];
            NSString *scheme = [[self baseURL] scheme];
            
            NSURLRequest *request = [TDOAuth URLRequestForPath:path
                                                    parameters:params
                                                          host:host
                                                   consumerKey:self.consumerToken.key
                                                consumerSecret:self.consumerToken.secret
                                                   accessToken:self.accessToken.key
                                                   tokenSecret:self.accessToken.secret
                                                        scheme:scheme
                                                 requestMethod:@"POST"
                                                  dataEncoding:TDOAuthContentTypeUrlEncodedForm
                                                  headerValues:nil
                                               signatureMethod:TDOAuthSignatureMethodHmacSha1];
            NSURLSessionDataTask *task;
            task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                [self.uploadProgressDictionary removeObjectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)task.taskIdentifier]];
                if (error) {
                    failureBlock(error);
                } else {
                    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    successBlock([self processResponseObject:responseObject resourceClass:[Photo class]]);
                }
            }];
            
            if (progress) {
                [self.uploadProgressDictionary setObject:[progress copy] forKey:[NSString stringWithFormat:@"%lu", (unsigned long)task.taskIdentifier]];
            }
            
            [task resume];
        }];
    }];
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

- (NSDictionary *)photoSizesDictionary {
    NSArray *sizes = @[@"320x320",
                       @"640x640"
                       ];
    return @{@"returnSizes": [sizes componentsJoinedByString:@","]};
}

- (NSDictionary *)sortByQueryDictionary:(NSString *)sortBy {
    return @{@"sortBy": sortBy};
}

- (NSDictionary *)albumsQueryDictionary:(NSString *)album {
    return @{@"album": album};
}

- (NSDictionary *)tagsQueryDictionary:(NSString *)tag {
    return @{@"tags": tag};
}

- (NSURL *)baseURL {
    return [[ConnectionManager sharedManager] baseURL];
}

#pragma mark - Oauth1Client

- (void)acquireOAuthAccessTokenWithPath:(NSString *)path
                           requestToken:(AFOAuth1Token *)requestToken
                           accessMethod:(NSString *)accessMethod
                                success:(void (^)(AFOAuth1Token *, id))success
                                failure:(void (^)(NSError *))failure {
    NSURL *baseURL = [[ConnectionManager  sharedManager] baseURL];
    NSString *host = [baseURL host];
    NSString *scheme = [baseURL scheme];
    NSURLRequest *request = [TDOAuth URLRequestForPath:path
                                            parameters:@{
                                                         @"oauth_token": requestToken.key,
                                                         @"oauth_verifier": requestToken.verifier
                                                         }
                                                  host:host
                                           consumerKey:self.consumerToken.key
                                        consumerSecret:self.consumerToken.secret
                                           accessToken:requestToken.key
                                           tokenSecret:requestToken.secret
                                                scheme:scheme
                                         requestMethod:accessMethod
                                          dataEncoding:TDOAuthContentTypeUrlEncodedForm
                                          headerValues:nil
                                       signatureMethod:TDOAuthSignatureMethodHmacSha1];
    
    
    NSURLSessionDataTask * dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failure(error);
        } else {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            AFOAuth1Token *accessToken = [[AFOAuth1Token alloc] initWithQueryString:dataString];
            if (accessToken) {
                success(accessToken, nil);
            } else {
                failure([NSError errorWithDomain:NSURLErrorDomain code:401 userInfo:@{@"info": dataString}]);
            }
            
        }
    }];
    
    [dataTask resume];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if ([self.uploadProgressDictionary objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)task.taskIdentifier]]) {
        void (^progress)(float) = self.uploadProgressDictionary[[NSString stringWithFormat:@"%lu", (unsigned long)task.taskIdentifier]];
        float prog = (float)totalBytesSent / (float)totalBytesExpectedToSend;
        progress(prog);
    }
}


@end
