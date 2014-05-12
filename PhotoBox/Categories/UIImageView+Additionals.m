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

static char const * const activityViewKey = "activityViewKey";

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

- (void)npr_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self npr_downloadImageWithURL:url placeholder:placeholder completion:nil];
}

- (void)npr_setImageWithURL:(NSURL *)url {
    [self npr_downloadImageWithURL:url placeholder:nil completion:nil];
}

- (void)npr_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completion:(void (^)(UIImage *))completion {
    [self npr_downloadImageWithURL:url placeholder:placeholder completion:completion];
}

- (void)npr_downloadImageWithURL:(NSURL *)url placeholder:(UIImage *)image completion:(void (^)(UIImage *))completion{
    UIActivityIndicatorView *act = [self npr_activityView];
    [act startAnimating];
    [self setImageWithURL:url placeholderImage:image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (act) {
            [act stopAnimating];
        }
        if (completion) {
            completion(image);
        }
    }];
}

- (UIActivityIndicatorView *)npr_activityView {
    UIActivityIndicatorView *activity = objc_getAssociatedObject(self, activityViewKey);
    if (!activity) {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activity setHidesWhenStopped:YES];
        [activity setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
        [self addSubview:activity];
        [activity setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
        objc_setAssociatedObject(self, activityViewKey, activity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return activity;
}

@end
