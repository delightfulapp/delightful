//
//  DelightfulTabBar.m
//  Delightful
//
//  Created by Nico Prananta on 11/23/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "DelightfulTabBar.h"

#import "UIView+Additionals.h"

#import "PureLayout.h"

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

- (void)setup {
    self.barTintColor = [UIColor tabBarTintColor];
    self.barStyle = UIBarStyleDefault;
    self.backgroundColor = [UIColor tabBarBackgroundColor];
    self.backgroundImage = nil;
    self.selectedImageTintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    
    [self setAccessibilityIdentifier:@"delightfultabbar"];
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
