//
//  PhotoCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoCell.h"

#import "Photo.h"

@interface PhotoCell ()

@property (nonatomic, strong) NSURL *shownImageURL;

@end

@implementation PhotoCell

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
    
    Photo *photo = (Photo *)item;
    [self.cellImageView setImageWithContentsOfURL:[NSURL URLWithString:photo.thumbnailStringURL] placeholderImage:nil];
}

@end
