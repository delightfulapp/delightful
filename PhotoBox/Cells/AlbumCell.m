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
    [self.albumTitle setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [self.albumTitleBackgroundView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];
    [self.albumTitle autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:-10];
}

- (void)setItem:(id)item {
    [super setItem:item];
    
    Album *album = (Album *)item;
    NSURL *imageURL = [album coverURL];
    [self.cellImageView setImageWithURL:imageURL placeholderImage:nil];
    [self.albumTitle setText:album.name];
}

@end
