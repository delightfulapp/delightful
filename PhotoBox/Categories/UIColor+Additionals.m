//
//  UIColor+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/11/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIColor+Additionals.h"

@implementation UIColor (Additionals)

// http://stackoverflow.com/questions/11598043/get-slightly-lighter-and-darker-color-from-uicolor

- (UIColor *)lighterColor
{
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                               green:MIN(g + 0.2, 1.0)
                                blue:MIN(b + 0.2, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)lightGrayTextColor {
    return [UIColor colorWithRed:0.769 green:0.769 blue:0.792 alpha:1.000];
}

@end
