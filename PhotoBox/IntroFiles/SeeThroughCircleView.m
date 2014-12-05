//
//  SeeThroughCircleView.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/24/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "SeeThroughCircleView.h"

@implementation SeeThroughCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.7];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
    [color setFill];
    [ovalPath fill];
    
    
    //// Text Drawing
    CGRect tmpRect = CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGRect topRect, topRemainderRect, middleRect, middleRemainderRect;
    CGRectDivide(tmpRect, &topRect, &topRemainderRect, CGRectGetHeight(tmpRect)*0.35, CGRectMinYEdge);
    CGRectDivide(topRemainderRect, &middleRect, &middleRemainderRect, CGRectGetHeight(tmpRect)*0.4, CGRectMinYEdge);
    CGRect textRect = middleRect;
    [[UIColor blackColor] setFill];
    NSMutableParagraphStyle *paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    {
        CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
        float fontSize = (self.fontSize > 0)?self.fontSize:CGRectGetHeight(rect)/4;
        UIFont *fontName = [UIFont systemFontOfSize:fontSize];
        if (self.fontName) {
            fontName = [UIFont fontWithName:self.fontName  size:fontSize];
        }
        [self.text drawInRect:textRect withAttributes:@{NSFontAttributeName:fontName, NSParagraphStyleAttributeName: paragraph}];
    }
    CGContextRestoreGState(context);
}

@end
