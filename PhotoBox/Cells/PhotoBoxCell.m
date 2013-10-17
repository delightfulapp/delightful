//
//  PhotoBoxCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxCell.h"

#import <UIView+AutoLayout.h>

@implementation PhotoBoxCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [self.cellImageView setCrossFade:NO];
    [self.cellImageView setBackgroundColor:[UIColor colorWithWhite:0.911 alpha:1.000]];
    [self.cellImageView setShouldHideIndicatorView:YES];
    [self.cellImageView setShouldHideErrorMessage:YES];
    [self.cellImageView setShouldHideProgressView:YES];
    [self.cellImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cellImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView];
    [self.cellImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];
    [self.cellImageView autoCenterInSuperview];
    [self.cellImageView setContentMode:UIViewContentModeScaleAspectFill];
}

@end
