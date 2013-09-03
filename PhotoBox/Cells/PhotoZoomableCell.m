//
//  PhotoZoomableCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoZoomableCell.h"

#import "Photo.h"

// no idea how to do the zooming inside scrollview inside collection view cell using auto layout. back to the ol' days.

@interface PhotoZoomableCell ()

@property (nonatomic, strong) NSURL *thumbnailURL;

@end

@implementation PhotoZoomableCell 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.scrollView setDelegate:self];
    self.thisImageview = [[NPRImageView alloc] initWithFrame:CGRectZero];
    [self.thisImageview setContentMode:UIViewContentModeScaleAspectFit];
    [self.thisImageview setCrossFade:NO];
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
    [self.scrollView setContentSize:size];
    
    self.scrollView.minimumZoomScale = ({
        CGRect scrollViewFrame = self.scrollView.frame;
        CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        minScale;
    });
    
    self.scrollView.maximumZoomScale = 4.0f;
    
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    [self centerScrollViewContents];
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
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.thisImageview;
}

- (void)setItem:(id)item {
    [super setItem:item];
    Photo *photo = (Photo *)item;
        
    if (![self.thumbnailURL.absoluteString isEqualToString:photo.thumbnailStringURL]) {
        if ([self hasDownloadedOriginalImage]) {
            [self loadOriginalImage];
        } else {
            [self.thisImageview setUseOriginal:NO];
            [self setImageSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetWidth(self.scrollView.frame))];
            [self.thisImageview setImageWithContentsOfURL:[NSURL URLWithString:photo.thumbnailStringURL] placeholderImage:nil];
        }
        
        self.thumbnailURL = [NSURL URLWithString:photo.thumbnailStringURL];
    }
}

- (void)loadOriginalImage {
    Photo *photo = (Photo *)self.item;
    [self setImageSize:CGSizeMake(photo.width, photo.height)];
    [self.thisImageview setUseOriginal:YES];
    [self.thisImageview setImageWithContentsOfURL:[NSURL URLWithString:photo.pathOriginal] placeholderImage:nil];
}

- (BOOL)hasDownloadedOriginalImage {
    Photo *photo = (Photo *)self.item;
    return [[NPRDiskCache sharedDiskCache] imageExistsOnDiskWithKey:photo.pathOriginal];
}

- (BOOL)isDownloadingOriginalImage {
    Photo *photo = (Photo *)self.item;
    return [[NPROperationQueue processingQueue] isDownloadingImageAtURLString:photo.pathOriginal];
}

- (UIImage *)originalImage {
    if ([self hasDownloadedOriginalImage]) {
        Photo *photo = (Photo *)self.item;
        return [[NPRDiskCache sharedDiskCache] imageFromDiskWithKey:photo.pathOriginal];
    }
    return nil;
}

@end
