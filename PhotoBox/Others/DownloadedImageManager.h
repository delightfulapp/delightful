//
//  DownloadedImageManager.h
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Photo;

@interface DownloadedImageManager : NSObject

+ (instancetype)sharedManager;

- (void)addPhoto:(Photo *)photo;

- (BOOL)photoHasBeenDownloaded:(Photo *)photo;

@end
