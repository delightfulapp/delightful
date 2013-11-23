//
//  UIView+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIView+Additionals.h"

@implementation UIView (Additionals)

- (CGRect)convertFrameRectToView:(UIView *)toView {
    if (![self isDescendantOfView:toView]) {
        return CGRectNull;
    }
    UIView *v = self;
    CGRect rect = self.frame;
    while (![v isKindOfClass:[toView class]]) {
        v = v.superview;
        rect = [v convertRect:rect toView:v.superview];
    }
    
    return rect;
}

- (UIView *)addTransparentGradientWithStartColor:(UIColor *)startColor {
    return [self addTransparentGradientWithStartColor:startColor fromStartPoint:CGPointMake(0.5, 0) endPoint:CGPointMake(0.5, 0.5)];
}

- (UIView *)addTransparentGradientWithStartColor:(UIColor *)startColor fromStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    UIView *colorView = [[UIView alloc] initWithFrame:self.bounds];
    [colorView setBackgroundColor:startColor];
    [self addSubview:colorView];
    CAGradientLayer *l = [CAGradientLayer layer];
    l.frame = self.bounds;
    l.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    l.startPoint = startPoint;
    l.endPoint = endPoint;
    colorView.layer.mask = l;
    return colorView;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setOriginX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
- (void)setOriginY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setPositionFromEdge:(MNCUIViewEdge)edge margin:(CGFloat)margin {
    if (edge == MNCUIViewLeftEdge) {
        [self setOriginX:margin];
    } else if (edge == MNCUIViewRightEdge) {
        [self setOriginX:CGRectGetWidth(self.superview.frame)-CGRectGetWidth(self.frame)-margin];
    } else if (edge == MNCUIViewTopEdge) {
        [self setOriginY:margin];
    } else if (edge == MNCUIViewBottomEdge) {
        [self setOriginY:CGRectGetHeight(self.superview.frame) - CGRectGetHeight(self.frame) - margin];
    }
}

- (void)setWidth:(CGFloat)width height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size = CGSizeMake(width, height);
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)fitToWidth:(CGFloat)width{
    if ([self isKindOfClass:[UILabel class]]) {
        [self setWidth:width];
        [self sizeToFit];
        [self setWidth:width];
    }
}

- (void)fitHeightToSubview:(UIView *)subview margin:(CGFloat)margin{
    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(subview.frame) + margin;
    self.frame = frame;
}

- (void)setPositionYSubview:(UIView *)subview1 under:(UIView *)subview2 margin:(CGFloat)margin {
    CGRect frame = subview1.frame;
    frame.origin.x = CGRectGetMinX(subview2.frame);
    frame.origin.y = CGRectGetMaxY(subview2.frame) + margin;
    subview1.frame = frame;
}

- (void)setPositionUnder:(UIView *)view margin:(CGFloat)margin {
    CGRect frame = self.frame;
    frame.origin.x = CGRectGetMinX(view.frame);
    frame.origin.y = CGRectGetMaxY(view.frame) + margin;
    self.frame = frame;
}

- (void)setCenterX:(CGFloat)x {
    self.center = CGPointMake(x, self.center.y);
}

- (void)setCenterY:(CGFloat)y {
    self.center = CGPointMake(self.center.x, y);
}

- (void)removeAllSubviews {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

- (void)cropCircle:(BOOL)crop radius:(CGFloat)radius {
    [self.layer setCornerRadius:(crop)?radius:0];
    [self.layer setMasksToBounds:crop];
}

- (void)setPositionInCenterOfSuperview {
    self.center = CGPointMake(CGRectGetWidth(self.superview.frame)/2, CGRectGetHeight(self.superview.frame)/2);
}

- (void)setPositionInCenterXOfSuperview {
    [self setCenterX:CGRectGetWidth(self.superview.frame)/2];
}

- (void)setPositionInCenterYOfSuperview {
    [self setCenterY:CGRectGetHeight(self.superview.frame)/2];
}

- (id)addSubviewClass:(Class)subviewClass {
    UIView *view = [[subviewClass alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:view];
    return view;
}

@end
