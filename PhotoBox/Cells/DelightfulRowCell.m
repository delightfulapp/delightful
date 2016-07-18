//
//  AlbumRowCell.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "DelightfulRowCell.h"

#import <QuartzCore/QuartzCore.h>

#import "PureLayout.h"

#import "UIView+Additionals.h"

@interface DelightfulRowCell ()

@property (nonatomic, assign) CGSize contentViewSize;

@end


@implementation DelightfulRowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [self.contentView setClipsToBounds:YES];
    [self setOpaque:YES];
    
    [self.cellImageView setBackgroundColor:[UIColor colorWithWhite:0.905 alpha:1.000]];
    [self.cellImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cellImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.cellImageView setClipsToBounds:YES];
    
    [self setupCellImageViewConstrains];
    [self setupTextLabelConstrains];
    
    [self.contentView bringSubviewToFront:self.textLabel];
    
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
    [self.textLabel setTextColor:[UIColor blackColor]];
}

- (void)setupCellImageViewConstrains {
    [self.cellImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView withOffset:-20];
    [self.cellImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self.cellImageView];
    [self.cellImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset:10];
    [self.cellImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
}

- (void)setupTextLabelConstrains {
    [self.textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.cellImageView withOffset:10];
    [self.textLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-10];
    [self.textLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
}

#pragma mark - Layout subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.contentView.frame.size, self.contentViewSize)) {
        self.contentViewSize = self.contentView.frame.size;
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(10, CGRectGetHeight(self.contentView.frame))];
        [linePath addLineToPoint:CGPointMake(CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame))];
        [self.lineLayer setPath:linePath.CGPath];
        
        linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(10, CGRectGetHeight(self.contentView.frame)-1)];
        [linePath addLineToPoint:CGPointMake(CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame)-1)];
        [self.lineShadowLayer setPath:linePath.CGPath];
    }
}

#pragma mark - Getters

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [self.contentView addSubviewClass:[UILabel class]];
    }
    return _textLabel;
}

- (CAShapeLayer *)lineLayer {
    if (!_lineLayer) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        [layer setStrokeColor:[UIColor colorWithRed:0.297 green:0.284 blue:0.335 alpha:1.000].CGColor];
        [layer setFillColor:[UIColor clearColor].CGColor];
        [layer setLineWidth:0.5];
        [self.contentView.layer addSublayer:layer];
        _lineLayer = layer;
    }
    return _lineLayer;
}

- (CAShapeLayer *)lineShadowLayer {
    if (!_lineShadowLayer) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        [layer setStrokeColor:[UIColor blackColor].CGColor];
        [layer setFillColor:[UIColor clearColor].CGColor];
        [layer setLineWidth:0.5];
        [self.contentView.layer addSublayer:layer];
        _lineShadowLayer = layer;
    }
    return _lineShadowLayer;
}

@end
