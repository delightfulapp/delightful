//
//  PhotoSharingManager.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/19/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"
#import "Bolts.h"

@interface PhotoSharingManager : NSObject

+ (instancetype)sharedManager;

- (void)shareLinkPhoto:(Photo *)photo image:(UIImage *)image fromViewController:(UIViewController *)fromViewController tokenFetchedBlock:(void(^)(id))tokenFetchedBlock completion:(void(^)(NSURL *URL))completion;

@end
