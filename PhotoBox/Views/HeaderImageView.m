//
//  HeaderImageView.m
//  Delightful
//
//  Created by Nico Prananta on 5/13/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "HeaderImageView.h"

@implementation HeaderImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [self.label.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.label.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.label.layer setShadowOpacity:0.8];
    [self.label.layer setShadowRadius:1];
    
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 200);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.imageView.frame = self.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
}

@end
