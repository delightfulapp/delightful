//
//  PhotoZoomableCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoZoomableCell.h"

#import "Photo.h"

#import "NPRImageView+Additionals.h"

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
    self.thisImageview = [[NPRImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetWidth(self.scrollView.frame))];
    [self.thisImageview setContentMode:UIViewContentModeScaleAspectFill];
    [self.thisImageview setCrossFade:NO];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.thisImageview setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.scrollView addSubview:self.thisImageview];
    [self.contentView addSubview:self.scrollView];
    self.scrollView.contentSize = self.thisImageview.frame.size;
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    
    self.scrollView.maximumZoomScale = 4.0f;
    self.scrollView.zoomScale = minScale;
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    [self.thisImageview setContentMode:UIViewContentModeScaleAspectFit];
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
        
        if ([self.thisImageview hasDownloadedOriginalImageAtURL:photo.pathOriginal]) {
            [self.thisImageview setImageWithContentsOfURL:[NSURL URLWithString:photo.pathOriginal] placeholderImage:nil];
        } else {
            [self.thisImageview setImageWithContentsOfURL:[NSURL URLWithString:photo.thumbnailStringURL] placeholderImage:nil];
        }
        
        self.thumbnailURL = [NSURL URLWithString:photo.thumbnailStringURL];
        
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale];
    }
}

- (void)loadOriginalImage {
    Photo *photo = (Photo *)self.item;
    [self.thisImageview setImageWithContentsOfURL:[NSURL URLWithString:photo.pathOriginal] placeholderImage:nil];
}

- (BOOL)hasDownloadedOriginalImage {
    Photo *photo = (Photo *)self.item;
    return [self.thisImageview hasDownloadedOriginalImageAtURL:photo.pathOriginal];
}

- (BOOL)isDownloadingOriginalImage {
    Photo *photo = (Photo *)self.item;
    return [self.thisImageview isDownloadingImageAtURLString:photo.pathOriginal];
}

- (UIImage *)originalImage {
    if ([self hasDownloadedOriginalImage]) {
        return self.thisImageview.image;
    }
    return nil;
}

@end
