//
//  AlbumRowCell.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumRowCell.h"

#import "Album.h"

#import <UIView+AutoLayout.h>

#import "UIImageView+Additionals.h"

@implementation AlbumRowCell

@synthesize item = _item;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setup {
    [super setup];
    
    [self.textLabel setTextColor:[UIColor whiteColor]];
    [self.textLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [self.cellImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.lineView setBackgroundColor:[UIColor clearColor]];
}

- (void)layoutSubviews {
    
}

#pragma mark - Setters

- (void)setItem:(id)item {
    if (_item != item) {
        _item = item;
        
        Album *album = (Album *)item;
        NSURL *imageURL = [album coverURL];
        
        [self.cellImageView npr_setImageWithURL:imageURL placeholderImage:nil filter:NPRImageFilterGaussianBlur];
        
        [self.textLabel setText:album.name];
    }
}

#pragma mark - Override constrains

- (void)setupCellImageViewConstrains {
    [self.cellImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView];
    [self.cellImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];
    [self.cellImageView autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.cellImageView autoCenterInSuperviewAlongAxis:ALAxisVertical];
}

- (void)setupTextLabelConstrains {
    [self.textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset:10];
    [self.textLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-10];
    [self.textLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:8];
}

@end
