//
//  UIImageView+Additionals.h
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NPRImageFilter) {
    NPRImageFilterNone,
    NPRImageFilterGaussianBlur
};

@interface UIImageView (Additionals)

- (void)npr_setImageWithURL:(NSURL *)URL placeholderImage:(UIImage *)image filter:(NPRImageFilter)filter;

- (void)npr_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end
