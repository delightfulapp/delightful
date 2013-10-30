//
//  PhotoZoomableCell.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoCell.h"

@protocol PhotoZoomableCellDelegate <NSObject>

- (void)didClosePhotosHorizontalViewController;
- (void)didCancelClosingPhotosHorizontalViewController;
- (void)didDragDownWithPercentage:(float)progress;


@end

@interface PhotoZoomableCell : PhotoCell <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *thisImageview;
@property (nonatomic, weak) id<PhotoZoomableCellDelegate> delegate;
@property (nonatomic, assign, getter = isClosingViewController) BOOL closingViewController;

- (void)loadOriginalImage;
- (BOOL)hasDownloadedOriginalImage;
- (BOOL)isDownloadingOriginalImage;
- (UIImage *)originalImage;
- (void)doTeasingGesture;

- (void)setZoomScale:(CGFloat)zoomScale;
- (void)setGrayscaleAndZoom:(BOOL)grayscale animated:(BOOL)animated;
- (void)setGrayscaleAndZoom:(BOOL)grayscale;
- (BOOL)isGrayscaled;
- (CGFloat)zoomScaleToFillScreen;
- (UIImageView *)grayImageView;

@end
