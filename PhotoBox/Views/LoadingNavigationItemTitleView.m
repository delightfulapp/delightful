//
//  LoadingNavigationItemTitleView.m
//  Delightful
//
//  Created by  on 12/25/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "LoadingNavigationItemTitleView.h"
#import "PureLayout.h"

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
        [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:0 relation:NSLayoutRelationGreaterThanOrEqual];
        [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self];
        [self.titleLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self];
        [self.indicatorView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
        [self.indicatorView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:8];
        [self.indicatorView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self];
    }
    return self;
}

@end
