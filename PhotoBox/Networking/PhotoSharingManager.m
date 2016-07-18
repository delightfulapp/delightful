//
//  PhotoSharingManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/19/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoSharingManager.h"

#import "APIClient.h"

#import "Photo+Additionals.h"

#import "UIViewController+Additionals.h"

@implementation PhotoSharingManager

+ (instancetype)sharedManager {
    static PhotoSharingManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PhotoSharingManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)shareLinkPhoto:(Photo *)photo image:(UIImage *)image fromViewController:(UIViewController *)fromViewController tokenFetchedBlock:(void (^)(id token))tokenFetchedBlock completion:(void (^)(NSURL *URL))completion {
    [[APIClient sharedClient] fetchSharingTokenForPhotoWithId:photo.photoId completionBlock:^(NSString *token) {
        if (tokenFetchedBlock) {
            tokenFetchedBlock(token);
        }
        if (token) {
            NSURL *sharedURL = [photo sharedURLWithToken:token];
            if (completion) {
                completion(sharedURL);
            }
        } else {
            PBX_LOG(@"No token");
        }
    }];
}

@end
