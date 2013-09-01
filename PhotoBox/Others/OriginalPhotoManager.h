//
//  OriginalPhotoManager.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OriginalPhotoManager : NSObject

+ (id)sharedManager;

- (BOOL)hasOriginalImageForStringURL:(NSString *)url;
- (UIImage *)originalImageForStringURL:(NSString *)url;
- (void)downloadOriginalPhotoAtURL:(NSURL *)url success:(void(^)(id))successBlock failure:(void(^)(id))failureBlock;

@end
