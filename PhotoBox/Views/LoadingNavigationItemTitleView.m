//
//  LoadingNavigationItemTitleView.m
//  Delightful
//
//  Created by  on 12/25/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "LoadingNavigationItemTitleView.h"
#import <UIView+AutoLayout.h>

@interface LoadingNavigationItemTitleView ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@end

@implementation LoadingNavigationItemTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        UILabel *titleLabel = [[UILabel alloc] initForAutoLayout];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [indicator setHidesWhenStopped:YES];
        [self addSubview:indicator];
        self.indicatorView = indicator;
        
        [self.titleLabel autoCenterInSuperview];
        [self.indicatorView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
        [self.indicatorView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:8];
    }
    return self;
}

@end
