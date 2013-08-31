//
//  AlbumCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumCell.h"
#import "Album.h"

@implementation AlbumCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setItem:(id)item {
    [super setItem:item];
    
    Album *album = (Album *)item;
    [self.cellImageView setImageWithContentsOfURL:[album albumCover:path200x200xCR] placeholderImage:nil];
}

@end
