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

@implementation PhotoBoxClient

+ (PhotoBoxClient *)sharedClient {
    static PhotoBoxClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[[ConnectionManager sharedManager] baseURL] key:[[ConnectionManager sharedManager] consumerKey] secret:[[ConnectionManager sharedManager] consumerSecret]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret{
    self = [super initWithBaseURL:url key:key secret:secret];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    AFOAuth1Token *accessToken = [[AFOAuth1Token alloc] initWithKey:[[ConnectionManager sharedManager] oauthToken] secret:[[ConnectionManager sharedManager] oauthSecret] session:nil expiration:nil renewable:YES];
    [AFOAuth1Token storeCredential:accessToken withIdentifier:@"photoBox"];
    [self setAccessToken:accessToken];
    
    return self;
}

- (void)getResource:(ResourceType)type
             action:(ActionType)action
         resourceId:(int)resourceId
               page:(int)page
            success:(void (^)(id))successBlock
            failure:(void (^)(NSError *))failureBlock {
}

- (void)getAlbumsForPage:(int)page
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock {
    [self getPath:[NSString stringWithFormat:@"/albums/list.json?page=%d",page]
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSArray *result = [responseObject objectForKey:@"result"];
              NSMutableArray *array = [NSMutableArray arrayWithCapacity:result.count];
              for (NSDictionary *dictionary in result) {
                  Album *album = [[Album alloc] initWithDictionary:dictionary];
                  [array addObject:album];
              }
              successBlock(array);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failureBlock(error);
          }];
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


@end
