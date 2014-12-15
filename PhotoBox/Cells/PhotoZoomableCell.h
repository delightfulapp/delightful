//
//  PhotoZoomableCell.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoCell.h"

@protocol PhotoZoomableCellDelegate <NSObject>

- (void)didReachPercentageToClosePhotosHorizontalViewController;
- (void)didCancelClosingPhotosHorizontalViewController;
- (void)didDragDownWithPercentage:(float)progress;

@end

@interface PhotoZoomableCell : UICollectionViewCell <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *thisImageview;
@property (nonatomic, weak) id<PhotoZoomableCellDelegate> delegate;
@property (nonatomic, assign, getter = isClosingViewController) BOOL closingViewController;
@property (nonatomic, strong) id item;

- (void)doTeasingGesture;
- (void)centerScrollViewContents;
- (void)setGrayscale:(BOOL)grayscale;
- (void)setZoomScale:(CGFloat)zoomScale;
- (void)setZoomToFillScreen:(BOOL)zoomToFillScreen;
- (BOOL)isGrayscaled;
- (CGFloat)zoomScaleToFillScreen;
- (UIImageView *)grayImageView;
- (void)setImageSize:(CGSize)size;

@end
