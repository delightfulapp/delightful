//
//  UIImage+Additionals.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additionals)

- (BOOL)isLandscape;

- (UIImage *)blurredImage;

- (UIImage *)grayscaleImage;

- (UIImage *)grayscaledAndBlurredImage;

- (UIImage *)grayscaledAndVignetteImage;

@end
