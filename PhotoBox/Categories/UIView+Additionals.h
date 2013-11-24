//
//  UIView+Additionals.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNCUIViewEdge) {
    MNCUIViewLeftEdge,
    MNCUIViewRightEdge,
    MNCUIViewTopEdge,
    MNCUIViewBottomEdge
};

@interface UIView (Additionals)

- (id)addSubviewClass:(Class)subviewClass;

- (CGRect)convertFrameRectToView:(UIView *)toView ;

- (UIView *)addTransparentGradientWithStartColor:(UIColor *)startColor;
- (UIView *)addTransparentGradientWithStartColor:(UIColor *)startColor fromStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

- (void)setOrigin:(CGPoint)origin;
- (void)setOriginX:(CGFloat)x;
- (void)setOriginY:(CGFloat)y;
- (void)setCenterX:(CGFloat)x;
- (void)setCenterY:(CGFloat)y;
- (void)setPositionFromEdge:(MNCUIViewEdge)edge margin:(CGFloat)margin;
- (void)setPositionInCenterOfSuperview;
- (void)setPositionInCenterXOfSuperview;
- (void)setPositionInCenterYOfSuperview;

- (void)setWidth:(CGFloat)width height:(CGFloat)height;
- (void)setHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;

- (void)fitToWidth:(CGFloat)width;
- (void)fitHeightToSubview:(UIView *)subview margin:(CGFloat)margin;

- (void)setPositionYSubview:(UIView *)subview1 under:(UIView *)subview2 margin:(CGFloat)margin;
- (void)setPositionUnder:(UIView *)view margin:(CGFloat)margin;

- (void)removeAllSubviews;

- (void)cropCircle:(BOOL)crop radius:(CGFloat)radius;

@end
