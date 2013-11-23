//
//  DelightfulTabBar.m
//  Delightful
//
//  Created by Nico Prananta on 11/23/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "DelightfulTabBar.h"

#import "UIView+Additionals.h"

#import <UIView+AutoLayout.h>

@interface DelightfulTabBar ()

@property (nonatomic, weak) CAShapeLayer *lineView;

@end

@implementation DelightfulTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.barTintColor = [UIColor colorWithRed:0.116 green:0.111 blue:0.131 alpha:1.000];
    self.barStyle = UIBarStyleDefault;
    self.backgroundColor = [UIColor colorWithRed:41.f/255.f green:39.f/255.f blue:46.f/255.f alpha:1];
    self.backgroundImage = nil;
    self.selectedImageTintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(CGRectGetWidth(self.frame)/2, 5)];
    [linePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame) - 5)];
    [self.lineView setPath:linePath.CGPath];
}


- (CAShapeLayer *)lineView {
    if (!_lineView) {
        CAShapeLayer *shape = [CAShapeLayer layer];
        [shape setStrokeColor:[UIColor colorWithRed:0.258 green:0.246 blue:0.290 alpha:1.000].CGColor];
        [shape setLineWidth:0.5];
        [self.layer addSublayer:shape];
        _lineView = shape;
    }
    return _lineView;
}

@end
