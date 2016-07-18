//
//  UIImage+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIImage+Additionals.h"

#import "GPUImage.h"

@implementation UIImage (Additionals)

- (BOOL)isLandscape {
    if (self.size.width > self.size.height) {
        return YES;
    }
    return NO;
}

- (UIImage *)blurredImage {
    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    return [blurFilter imageByFilteringImage:self];
}

- (UIImage *)grayscaleImage {
    GPUImageGrayscaleFilter *gray = [[GPUImageGrayscaleFilter alloc] init];
    return [gray imageByFilteringImage:self];
}

- (UIImage *)grayscaledAndBlurredImage {
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:self];
    GPUImageGrayscaleFilter *grayFilter = [[GPUImageGrayscaleFilter alloc] init];
    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [grayFilter addTarget:blurFilter];
    [imagePicture addTarget:grayFilter];
    [blurFilter useNextFrameForImageCapture];
    [imagePicture processImage];

    return [blurFilter imageFromCurrentFramebuffer];
}

- (UIImage *)grayscaledAndVignetteImage {
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:self];
    GPUImageGrayscaleFilter *gray = [[GPUImageGrayscaleFilter alloc] init];
    GPUImageVignetteFilter *vignette = [[GPUImageVignetteFilter alloc] init];
    [gray addTarget:vignette];
    [imagePicture addTarget:gray];
    [imagePicture processImage];
    
    return [gray imageFromCurrentFramebuffer];
}

@end
