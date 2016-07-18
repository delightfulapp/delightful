//
//  PhotoZoomableCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoZoomableCell.h"
#import "Photo.h"
#import "SDWebImageManager.h"
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
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    [self.scrollView setAlwaysBounceHorizontal:NO];
    [self.scrollView setAlwaysBounceVertical:YES];
    
    [self.scrollView setDelegate:self];
    self.thisImageview = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.thisImageview setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
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
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return;
    }
    
    self.thisImageview.frame = ({
        CGRect frame = self.thisImageview.frame;
        frame.size = size;
        frame;
    });
    [self.thisImageview setNeedsLayout];
    [self.scrollView setContentSize:CGSizeMake(size.width, size.height)];
    
    CGFloat minimumZoomScale = ({
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
        maxScale;
    });
    self.scrollView.maximumZoomScale = MIN(MAX(maxScale, maxZoomScaleFillScreen), 1);
    self.scrollView.minimumZoomScale = MIN(minimumZoomScale, 1);
    
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
    CGPoint point = [recognizer locationInView:self.thisImageview];
    CGFloat scale = 0;
    if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
        scale = self.scrollView.minimumZoomScale;
        [self.scrollView setZoomScale:scale animated:YES];
        // this is to fix the very weird bug  in iPhone 6plus where cannot change page after double tap to max zoom
        [self setImageSize:CGSizeMake(self.thisImageview.image.size.width , self.thisImageview.image.size.height)];
        // end of fix
        [self centerScrollViewContents];
    } else {
        [self.scrollView zoomToRect:CGRectMake(point.x - 10, point.y - 10, 20, 20) animated:YES];
    }
}

- (void)centerScrollViewContents {
    if (self.isClosingViewController) {
        return;
    }
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.thisImageview.image && self.thisImageview.image.size.width > 0) {
        Photo *photo = (Photo *)self.item;
        if (photo.normalImage) {
            [self setImageSize:CGSizeMake(photo.normalImage.width.floatValue, photo.normalImage.height.floatValue)];
        } else {
            [self setImageSize:CGSizeMake(photo.originalImage.width.floatValue, photo.originalImage.height.floatValue)];
        }
        
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
            self.closingViewController = YES;
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReachPercentageToClosePhotosHorizontalViewController)]) {
        [self.delegate didReachPercentageToClosePhotosHorizontalViewController];
        
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
        
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 1;
        self.scrollView.zoomScale = 1;
        
        Photo *photo = (Photo *)item;
        
        if (photo.normalImage) {
            if (![self.thumbnailURL.absoluteString isEqualToString:photo.normalImage.urlString]) {
                self.thumbnailURL = [NSURL URLWithString:photo.normalImage.urlString];
                CGFloat width, height;
                NSURL *URL;
                width = [photo.normalImage.width floatValue];
                height = [photo.normalImage.height floatValue];
                URL = [NSURL URLWithString:photo.normalImage.urlString];
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
            }
        } else {
            if (photo.originalImage) {
                CGSize size = CGSizeMake(photo.originalImage.width.floatValue, photo.originalImage.height.floatValue);
                [self setImageSize:size];
                [[self.thisImageview npr_activityView] setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
                [[self.thisImageview npr_activityView] setColor:[UIColor redColor]];
                [self.thisImageview npr_setImageWithURL:[NSURL URLWithString:photo.originalImage.urlString] placeholderImage:nil];
            }
        }
    }
   
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

- (void)setZoomToFillScreen:(BOOL)zoomToFillScreen {
    if (zoomToFillScreen) {
        [self setZoomScale:[self zoomScaleToFillScreen]];
    } else {
        [self setZoomScale:self.scrollView.minimumZoomScale];
    }
    [self centerScrollViewContents];
}

- (void)setGrayscale:(BOOL)grayscale {
    if (grayscale) {
        if (self.thisImageview.image) {
            UIImage *grayscaleImage = (self.thisImageview.image.size.width < 1000)?[self.thisImageview.image grayscaledAndBlurredImage]:[self.thisImageview.image grayscaleImage];
            UIImageView *grayImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[grayscaleImage CGImage] scale:1 orientation:UIImageOrientationUp]];
            [grayImageView setTag:PBX_GRAY_IMAGE_VIEW];
            [grayImageView setFrame:self.thisImageview.bounds];
            [grayImageView setAlpha:1];
            [self.thisImageview addSubview:grayImageView];
        }
    } else {
        UIImageView *grayImageView = (UIImageView *)[self.thisImageview viewWithTag:PBX_GRAY_IMAGE_VIEW];
        if (grayImageView) {
            [grayImageView removeFromSuperview];
        }
    }
}

- (void)setZoomScale:(CGFloat)zoomScale {
    [self.scrollView setZoomScale:zoomScale];
}

- (BOOL)isGrayscaled {
    UIImageView *grayImageView = (UIImageView *)[self.thisImageview viewWithTag:PBX_GRAY_IMAGE_VIEW];
    return (grayImageView)?YES:NO;
}

- (void)prepareForReuse {
    [self setNeedsLayout];
}

@end
