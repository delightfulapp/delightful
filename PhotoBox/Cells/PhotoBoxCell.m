//
//  PhotoBoxCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxCell.h"

#import "PureLayout.h"

@implementation PhotoBoxCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [self.cellImageView setBackgroundColor:[UIColor colorWithWhite:0.905 alpha:1.000]];
    [self.cellImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.cellImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.cellImageView setClipsToBounds:YES];
    
    [self setupCellImageViewConstrains];
}

- (void)setupCellImageViewConstrains {
    [self.cellImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView];
    [self.cellImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];
    [self.cellImageView autoCenterInSuperview];
}

- (UIImageView *)cellImageView {
    if (!_cellImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        _cellImageView = imageView;
    }
    
    return _cellImageView;
}

@end
