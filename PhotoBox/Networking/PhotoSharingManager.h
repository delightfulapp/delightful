//
//  PhotoSharingManager.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/19/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Photo.h"

@interface PhotoSharingManager : NSObject

+ (instancetype)sharedManager;

- (void)sharePhoto:(Photo *)photo image:(UIImage *)image completion:(void(^)())completion;

@end
