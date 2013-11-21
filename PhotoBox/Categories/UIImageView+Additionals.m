//
//  UIImageView+Additionals.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIImageView+Additionals.h"

#import <SDWebImageManager.h>

#import <UIImageView+WebCache.h>

#import <objc/runtime.h>

#import "UIImage+Additionals.h"

static char operationKey;

@implementation UIImageView (Additionals)

- (void)npr_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder filter:(NPRImageFilter)filter {
    [self cancelCurrentImageLoad];
    
    self.image = placeholder;
    
    if (url)
    {
        __weak UIImageView *wself = self;
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                                             {
                                                 if (!wself) return;
                                                 if (filter==NPRImageFilterGaussianBlur) {
                                                     image = [image blurredImage];
                                                 }
                                                 
                                                 dispatch_main_sync_safe(^
                                                                         {
                                                                             if (!wself) return;
                                                                             if (image)
                                                                             {
                                                                                 wself.image = image;
                                                                                 [wself setNeedsLayout];
                                                                             }
                                                                         });
                                             }];
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
