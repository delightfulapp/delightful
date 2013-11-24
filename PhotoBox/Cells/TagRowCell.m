//
//  TagRowCell.m
//  Delightful
//
//  Created by Nico Prananta on 11/24/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "TagRowCell.h"

#import "Tag.h"

#import <UIView+AutoLayout.h>

@implementation TagRowCell

@synthesize item = _item;


- (void)setupCellImageViewConstrains {
    [self.cellImageView autoSetDimensionsToSize:CGSizeZero];
    [self.cellImageView autoPinEdge:ALEdgeLeft toPositionInSuperview:0];
    [self.cellImageView autoPinEdge:ALEdgeTop toPositionInSuperview:0];
}

- (void)setup {
    [super setup];
    
    [self.cellImageView setHidden:YES];
}

#pragma mark - Setters

- (void)setItem:(id)item {
    if (_item != item) {
        _item = item;
        
        Tag *tag = (Tag *)item;
        
        [self.textLabel setAttributedText:[self attributedTextForAlbumName:tag.tagId count:tag.count.intValue]];
    }
}

@end
