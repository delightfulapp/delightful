//
//  AlbumSectionHeaderView.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumSectionHeaderView.h"

#import <UIView+AutoLayout.h>

#import <AMBlurView.h>

#import "UIView+Additionals.h"

#import "UIViewController+DelightfulViewControllers.h"

@interface AlbumSectionHeaderView ()

@property (nonatomic, weak) UIImageView *arrowImage;

@property (nonatomic, weak) CAShapeLayer *lineLayer;

@property (nonatomic, weak) CAShapeLayer *lineShadowLayer;

@property (nonatomic, assign) CGSize contentViewSize;

@end

@implementation AlbumSectionHeaderView

- (void)setup {
    [super setup];
    
    [self.titleLabel setHidden:YES];
    [self.locationLabel setTextColor:[UIColor whiteColor]];
    
}

- (UIImageView *)arrowImage {
    if (!_arrowImage) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"right.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setTintColor:[UIColor whiteColor]];
        [self addSubview:imageView];
        _arrowImage = imageView;
    }
    return _arrowImage;
}

- (CAShapeLayer *)lineLayer {
    if (!_lineLayer) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        [layer setStrokeColor:[UIColor colorWithRed:0.297 green:0.284 blue:0.335 alpha:1.000].CGColor];
        [layer setFillColor:[UIColor clearColor].CGColor];
        [layer setLineWidth:0.5];
        [self.layer addSublayer:layer];
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
        [self.layer addSublayer:layer];
        _lineShadowLayer = layer;
    }
    return _lineShadowLayer;
}

- (void)setupConstrains {
    CGFloat visibleWidth = [UIViewController leftViewControllerVisibleWidth];
    CGFloat offset = visibleWidth - CGRectGetWidth(self.frame) - 20;
    [self.arrowImage autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.arrowImage autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:offset];
    
    [self.locationLabel autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.locationLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:10];
    
    [self.titleLabel autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:offset];
    
    [self.blurView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
    [self.blurView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self.blurView autoCenterInSuperview];
}

#pragma mark - Layout subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.frame.size, self.contentViewSize)) {
        self.contentViewSize = self.frame.size;
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(10, CGRectGetHeight(self.frame))];
        [linePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [self.lineLayer setPath:linePath.CGPath];
        
        linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(10, CGRectGetHeight(self.frame)-1)];
        [linePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-1)];
        [self.lineShadowLayer setPath:linePath.CGPath];
    }
}

#pragma mark - Setters

- (void)setText:(NSString *)text {
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor blackColor]];
    [shadow setShadowOffset:CGSizeMake(0, -1)];
    [shadow setShadowBlurRadius:0];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{NSShadowAttributeName: shadow}];
    
    [self.locationLabel setAttributedText:attributedString];
}

@end
