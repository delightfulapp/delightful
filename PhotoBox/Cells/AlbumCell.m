//
//  AlbumCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumCell.h"
#import "Album.h"

#import <UIView+AutoLayout.h>

@implementation AlbumCell

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
    
    [self setAlbumTitleConstraint];
}

- (void)setAlbumTitleConstraint {
    [self.albumTitle setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:20]];
    [self.albumTitleBackgroundView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];
    NSLayoutConstraint *constrain = [self.albumTitleBackgroundView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView withMultiplier:0.4];
    [constrain setPriority:UILayoutPriorityDefaultLow];
    constrain = [self.albumTitleBackgroundView autoSetDimension:ALDimensionHeight toSize:80 relation:NSLayoutRelationLessThanOrEqual];
    [constrain setPriority:UILayoutPriorityRequired];
    [self.albumTitle autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:0];
}

- (void)setItem:(id)item {
    [super setItem:item];
    
    Album *album = (Album *)item;
    NSURL *imageURL = [album albumCover:path200x200xCR];
    [self.cellImageView setImageWithContentsOfURL:imageURL placeholderImage:nil];
    [self.albumTitle setText:album.name];
}

@end
