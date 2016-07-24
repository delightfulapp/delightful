//
//  LeftPanelHeaderView.m
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "LeftPanelHeaderView.h"

#import "PureLayout.h"

@interface LeftPanelHeaderView ()

@property (nonatomic, strong) CAShapeLayer *separatorLine;
@property (nonatomic, strong) CAShapeLayer *separatorLine2;

@end

@implementation LeftPanelHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.galleryArrow setImage:[[UIImage imageNamed:@"right.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.downloadedArrow setImage:[[UIImage imageNamed:@"right.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.favoriteArrow setImage:[[UIImage imageNamed:@"right.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, CGRectGetMaxY(self.favoriteButton.frame) + 10);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.separatorLine) {
        self.separatorLine = [CAShapeLayer layer];
        [self.separatorLine setLineWidth:0.5];
        [self.separatorLine setStrokeColor:[UIColor albumsBackgroundColor].CGColor];
        
        [self.layer addSublayer:self.separatorLine];
    }
    if (!self.separatorLine2) {
        self.separatorLine2 = [CAShapeLayer layer];
        [self.separatorLine2 setLineWidth:0.5];
        [self.separatorLine2 setStrokeColor:[UIColor albumsBackgroundColor].CGColor];
        
        [self.layer addSublayer:self.separatorLine2];
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat yPoint = CGRectGetMaxY(self.galleryButton.frame) + 5;
    [path moveToPoint:CGPointMake(CGRectGetMinX(self.galleryButton.frame), yPoint)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.galleryButton.frame), yPoint)];
    [self.separatorLine setPath:path.CGPath];
    
    path = [UIBezierPath bezierPath];
    yPoint = CGRectGetMaxY(self.downloadedButton.frame) + 5;
    [path moveToPoint:CGPointMake(CGRectGetMinX(self.downloadedButton.frame), yPoint)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.downloadedButton.frame), yPoint)];
    [self.separatorLine2 setPath:path.CGPath];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.alpha > 0 && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}

@end
