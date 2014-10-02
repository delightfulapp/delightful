//
//  PhotoZoomableCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoZoomableCell.h"

#import "Photo.h"

#import <SDWebImageManager.h>

#import "UIImage+Additionals.h"
#import "UIWindow+Additionals.h"
#import "UIImageView+Additionals.h"

#define PBX_GRAY_IMAGE_VIEW 12381

@interface SDWebImageManager ()

- (NSString *)cacheKeyForURL:(NSURL *)url;

@end

// no idea how to do the zooming inside scrollview inside collection view cell using auto layout. back to the ol' days.

@interface PhotoZoomableCell () {
    CGPoint draggingPoint;
    BOOL isZooming;
    CGFloat maxZoomScale;
}

@property (nonatomic, strong) NSURL *thumbnailURL;

@end

@implementation PhotoZoomableCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    NSLog(@"Setup zoomable cell %p", self);
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    [self.scrollView setAlwaysBounceHorizontal:NO];
    [self.scrollView setAlwaysBounceVertical:YES];
    
    [self.scrollView setDelegate:self];
    self.thisImageview = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.thisImageview setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.thisImageview setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.scrollView addSubview:self.thisImageview];
    [self.contentView addSubview:self.scrollView];
    
    [self setImageSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetWidth(self.scrollView.frame))];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
}

- (void)setImageSize:(CGSize)size {
    self.scrollView.zoomScale = 1;
    
    self.thisImageview.frame = ({
        CGRect frame = self.thisImageview.frame;
        frame.size = size;
        frame;
    });
    [self.thisImageview setNeedsLayout];
    [self.scrollView setContentSize:CGSizeMake(size.width, size.height)];
    
    self.scrollView.minimumZoomScale = ({
        CGRect scrollViewFrame = self.scrollView.frame;
        CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        minScale;
    });
    
    CGFloat maxZoomScaleFillScreen = [self zoomScaleToFillScreen];
    CGFloat maxScale = ({
        CGRect scrollViewFrame = self.scrollView.frame;
        CGFloat scaleWidth = self.scrollView.contentSize.width / scrollViewFrame.size.width;
        CGFloat scaleHeight = self.scrollView.contentSize.height / scrollViewFrame.size.height;
        CGFloat maxScale = MAX(scaleWidth, scaleHeight);
        if (maxScale > 1) {
            maxScale = 1;
        } else if (maxScale < 1) {
            maxScale = 1;
        }
        maxScale;
    });
    self.scrollView.maximumZoomScale = MAX(maxScale, maxZoomScaleFillScreen);
    
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    [self centerScrollViewContents];
}

- (CGFloat)zoomScaleToFillScreen {
    CGFloat zoom = 0;
    CGFloat frameHeight = CGRectGetHeight([[UIWindow appWindow] frame]);
    CGFloat imageHeight = self.thisImageview.bounds.size.height;
    zoom = frameHeight/imageHeight;
    return zoom;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    }
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.thisImageview.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.thisImageview.frame = contentsFrame;
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        [self.scrollView setDirectionalLockEnabled:YES];
    } else {
        [self.scrollView setDirectionalLockEnabled:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
    if (scrollView.zoomScale == self.scrollView.minimumZoomScale && !isZooming) {
        float deltaY = fabsf(self.scrollView.contentOffset.y - draggingPoint.y);
        CGFloat maxDelta = 100;
        deltaY = MIN(deltaY, maxDelta);
        CGFloat alpha = (deltaY)/(maxDelta);
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDragDownWithPercentage:)]) {
            [self.delegate didDragDownWithPercentage:alpha];
        }
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    isZooming = YES;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    isZooming = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        draggingPoint = scrollView.contentOffset;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        float deltaY = fabsf(self.scrollView.contentOffset.y - draggingPoint.y);
        if (deltaY > 50) {
            [self notifyDelegateToCloseHorizontalScrollingViewController];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelClosingPhotosHorizontalViewController)]) {
                [self.delegate didCancelClosingPhotosHorizontalViewController];
            }
        }
    }
}

- (void)notifyDelegateToCloseHorizontalScrollingViewController {
    [self setHaveShownGestureTeasing];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClosePhotosHorizontalViewController)]) {
        [self.delegate didClosePhotosHorizontalViewController];
        
        // remove delegate so that didDragDownWithPercentage will not be called anymore. it gives an annoying white flash.
        self.delegate = nil;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.thisImageview;
}

- (void)setItem:(id)item {
    if (_item != item) {
        _item = item;
        
        Photo *photo = (Photo *)item;
        
        if (![self.thumbnailURL.absoluteString isEqualToString:photo.normalImage.urlString]) {
            CGFloat width, height;
            NSURL *URL;
            if (photo.normalImage) {
                width = [photo.normalImage.width floatValue];
                height = [photo.normalImage.height floatValue];
                URL = [NSURL URLWithString:photo.normalImage.urlString];
            } else {
                width = [photo.width floatValue];
                height = [photo.height floatValue];
                URL = photo.pathOriginal;
            }
            [self setImageSize:CGSizeMake(width, height)];
            [[self.thisImageview npr_activityView] setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
            [[self.thisImageview npr_activityView] setColor:[UIColor redColor]];
            UIImage *placeholderImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:photo.thumbnailImage.urlString]]];
            if (!placeholderImage) {
                placeholderImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:photo.photo200x200.urlString]]];
                if (!placeholderImage) {
                    placeholderImage = photo.asAlbumCoverImage;
                    if (!placeholderImage) {
                        placeholderImage = photo.placeholderImage;
                    }
                }
            }
            [self.thisImageview npr_setImageWithURL:URL placeholderImage:placeholderImage];
            
            self.thumbnailURL = [NSURL URLWithString:photo.normalImage.urlString];
        }
    }
   
}

- (void)loadOriginalImage {
    Photo *photo = (Photo *)self.item;
    [self setImageSize:CGSizeMake([photo.width floatValue], [photo.height floatValue])];
    [self.thisImageview setImageWithURL:[NSURL URLWithString:photo.pathOriginal.absoluteString] placeholderImage:nil];
}

- (BOOL)hasDownloadedOriginalImage {
    return NO;
//    Photo *photo = (Photo *)self.item;
//    return [self.thisImageview hasDownloadedOriginalImageAtURL:photo.pathOriginal.absoluteString];
}

- (BOOL)isDownloadingOriginalImage {
    return NO;
//    Photo *photo = (Photo *)self.item;
//    return [self.thisImageview isDownloadingImageAtURLString:photo.pathOriginal.absoluteString];
}

- (UIImage *)originalImage {
    if ([self hasDownloadedOriginalImage]) {
        return self.thisImageview.image;
    }
    return nil;
}

- (UIImageView *)grayImageView {
    return (UIImageView *)[self.thisImageview viewWithTag:PBX_GRAY_IMAGE_VIEW];
}

#pragma mark - Gesture Teasing

- (void)doTeasingGesture {
    if (!self.isClosingViewController) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:PBX_DID_SHOW_SCROLL_UP_AND_DOWN_TO_CLOSE_FULL_SCREEN_PHOTO]) {
            [self startTeasing];
        }
    }
}

- (void)startTeasing {
    PBX_LOG(@"Do teaasing gesture");
    [self scrollViewWillBeginDragging:self.scrollView];
    [UIView animateWithDuration:0.5 animations:^{
        [self.scrollView setContentOffset:CGPointMake(0, -50) animated:NO];
    } completion:^(BOOL finished) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self setHaveShownGestureTeasing];
    }];
}

- (void)setHaveShownGestureTeasing {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PBX_DID_SHOW_SCROLL_UP_AND_DOWN_TO_CLOSE_FULL_SCREEN_PHOTO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Photo Detail

- (void)setGrayscaleAndZoom:(BOOL)grayscale animated:(BOOL)animated {
    if (grayscale) {
        if (self.thisImageview.image) {
            CGFloat maxZoom = [self zoomScaleToFillScreen];
            UIImage *grayscaleImage = (self.thisImageview.image.size.width < 1000)?[self.thisImageview.image grayscaledAndBlurredImage]:[self.thisImageview.image grayscaleImage];
            UIImageView *grayImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[grayscaleImage CGImage] scale:1 orientation:UIImageOrientationUp]];
            [grayImageView setTag:PBX_GRAY_IMAGE_VIEW];
            [grayImageView setFrame:self.thisImageview.bounds];
            [grayImageView setAlpha:0];
            [self.thisImageview addSubview:grayImageView];
            
            if (animated) {
                maxZoomScale = self.scrollView.maximumZoomScale;
                self.scrollView.maximumZoomScale = maxZoom;
                [self.scrollView setZoomScale:maxZoom animated:YES];
                [UIView animateWithDuration:0.5 animations:^{
                    [grayImageView setAlpha:1];
                }];
            } else {
                [grayImageView setAlpha:1];
            }
        }
    } else {
        UIImageView *grayImageView = (UIImageView *)[self.thisImageview viewWithTag:PBX_GRAY_IMAGE_VIEW];
        if (grayImageView) {
            if (animated) {
                [self.scrollView setMaximumZoomScale:maxZoomScale];
                [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
                [UIView animateWithDuration:0.5 animations:^{
                    [grayImageView setAlpha:0];
                    
                } completion:^(BOOL finished) {
                    if (finished) {
                        [grayImageView removeFromSuperview];
                    }
                }];
            } else {
                [grayImageView removeFromSuperview];
                [self.scrollView setZoomScale:self.scrollView.minimumZoomScale];
            }
        }
    }
}

- (void)setGrayscaleAndZoom:(BOOL)grayscale {
    [self setGrayscaleAndZoom:grayscale animated:YES];
}

- (void)setZoomScale:(CGFloat)zoomScale {
    [self.scrollView setZoomScale:zoomScale];
}

- (BOOL)isGrayscaled {
    UIImageView *grayImageView = (UIImageView *)[self.thisImageview viewWithTag:PBX_GRAY_IMAGE_VIEW];
    return (grayImageView)?YES:NO;
}


@end
