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

@end
