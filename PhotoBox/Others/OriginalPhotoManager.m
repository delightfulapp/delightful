//
//  OriginalPhotoManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "OriginalPhotoManager.h"

@implementation OriginalPhotoManager

+ (id)sharedManager {
    static OriginalPhotoManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (BOOL)hasOriginalImageForStringURL:(NSString *)url {
    return NO;
}

- (UIImage *)originalImageForStringURL:(NSString *)url {
    return nil;
}

@end
