//
//  PhotoSharingManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/19/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoSharingManager.h"

#import "PhotoBoxClient.h"

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

- (void)sharePhoto:(Photo *)photo image:(UIImage *)image tokenFetchedBlock:(void (^)(id token))tokenFetchedBlock completion:(void (^)())completion {
    [[PhotoBoxClient sharedClient] fetchSharingTokenForPhotoWithId:photo.photoId completionBlock:^(NSString *token) {
        if (tokenFetchedBlock) {
            tokenFetchedBlock(token);
        }
        if (token) {
            NSURL *sharedURL = [photo sharedURLWithToken:token];
            NSLog(@"Shared URL = %@", sharedURL.absoluteString);
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] openActivityPickerForURL:sharedURL completion:completion];
        } else {
            NSLog(@"No token");
        }
    }];
}

@end
