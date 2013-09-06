//
//  PhotoBoxClient.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxClient.h"

#import "AFJSONRequestOperation.h"
#import "ConnectionManager.h"

#import "Album.h"
#import "Photo.h"
#import "Tag.h"

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
    self = [super initWithBaseURL:url key:key secret:secret];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    if ([[ConnectionManager sharedManager] isUserLoggedIn]) {
        [self setAccessToken:[[ConnectionManager sharedManager] oauthToken]];
    }
    [self setParameterEncoding:AFFormURLParameterEncoding];
    
    return self;
}

- (void)getResource:(ResourceType)type
             action:(ActionType)action
         resourceId:(NSString *)resourceId
               page:(int)page
            success:(void (^)(id))successBlock
            failure:(void (^)(NSError *))failureBlock {
    if ([[ConnectionManager sharedManager] isUserLoggedIn]) {
        switch (action) {
            case ListAction:{
                if (type == AlbumResource) [self getAlbumsForPage:page success:successBlock failure:failureBlock];
                else if (type == PhotoResource) [self getPhotosInAlbum:resourceId page:page success:successBlock failure:failureBlock];
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
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    [self getPath:[NSString stringWithFormat:@"/albums/list.json?page=%d",page]
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              successBlock([self processResponseObject:responseObject resourceClass:[Album class]]);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error %@", error);
              failureBlock(error);
          }];
}

- (void)getPhotosInAlbum:(NSString *)albumId page:(int)page success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    NSString *album = [NSString stringWithFormat:@"/album-%@", albumId];
    if (!albumId) album = @"";
    NSString *path = [NSString stringWithFormat:@"/photos%@/list.json?page=%d&%@", album, page, [self photoSizesString]];
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock([self processResponseObject:responseObject resourceClass:[Photo class]]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failureBlock(error);
    }];
}

- (void)getTagsWithSuccess:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    [self getPath:@"/tags/list.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock([self processResponseObject:responseObject resourceClass:[Tag class]]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
    }];
}

- (void)getAllPhotosOnPage:(int)page success:(void (^)(id))successBlock failure:(void (^)(NSError *))failureBlock {
    [self getPhotosInAlbum:nil page:page success:successBlock failure:failureBlock];
}

- (NSArray *)processResponseObject:(NSDictionary *)responseObject resourceClass:(Class)resource {
    NSArray *result = [responseObject objectForKey:@"result"];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:result.count];
    for (NSDictionary *objectDictionary in result) {
        id object = [[resource alloc] initWithDictionary:objectDictionary];
        if (object) {
            [array addObject:object];
        }
    }
    return array;
}

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
    NSArray *sizes = @[@"200x200xCR",
                       @"640x640"
                       ];
    return AFQueryStringFromParametersWithEncoding(@{@"returnSizes": [sizes componentsJoinedByString:@","]}, NSUTF8StringEncoding);
}


@end
