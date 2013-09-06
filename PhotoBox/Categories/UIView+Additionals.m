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

- (void)addTransparentGradientWithStartColor:(UIColor *)startColor {
    UIView *colorView = [[UIView alloc] initWithFrame:self.bounds];
    [colorView setBackgroundColor:startColor];
    [self addSubview:colorView];
    CAGradientLayer *l = [CAGradientLayer layer];
    l.frame = self.bounds;
    l.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    l.endPoint = CGPointMake(0.5, 0.5);
    colorView.layer.mask = l;
}

@end
