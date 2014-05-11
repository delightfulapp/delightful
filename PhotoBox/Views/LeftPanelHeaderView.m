//
//  LeftPanelHeaderView.m
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "LeftPanelHeaderView.h"

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

- (void)setup {
    [self setBackgroundColor:[UIColor tabBarTintColor]];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, CGRectGetMaxY(self.favoritesButton.frame) + 10);
}

@end
