//
//  AlbumSectionHeaderView.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumSectionHeaderView.h"

#import <UIView+AutoLayout.h>

#import <AMBlurView.h>

@implementation AlbumSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupConstrains {
    
    [self.locationLabel autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.locationLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:10];
    
    [self.titleLabel autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-80];
    
    [self.blurView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
    [self.blurView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self.blurView autoCenterInSuperview];
}

@end
