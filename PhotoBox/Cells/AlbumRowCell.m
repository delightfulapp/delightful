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
    [self.textLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [self.textLabel setNumberOfLines:2];
    [self.cellImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.lineView setBackgroundColor:[UIColor colorWithRed:0.297 green:0.284 blue:0.335 alpha:1.000]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.cellImageView.layer setCornerRadius:CGRectGetWidth(self.cellImageView.frame)/2];
}

#pragma mark - Setters

- (void)setItem:(id)item {
    if (_item != item) {
        _item = item;
        
        Album *album = (Album *)item;
        NSURL *imageURL = [album coverURL];
        
        [self.cellImageView setImageWithURL:imageURL];
        
        [self.textLabel setText:album.name];
    }
}

#pragma mark - Override constrains

- (void)setupTextLabelConstrains {
    [self.textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.cellImageView withOffset:10];
    [self.textLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-80];
    [self.textLabel autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
}

@end
