//
//  FooterLoadingReusableView.m
//  Delightful
//
//  Created by  on 10/28/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "FooterLoadingReusableView.h"

#import "PureLayout.h"

@implementation FooterLoadingReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:indicator];
        [indicator autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [indicator autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self withOffset:10];
        [indicator startAnimating];
        
        [self setClipsToBounds:YES];
    }
    return self;
}

@end
