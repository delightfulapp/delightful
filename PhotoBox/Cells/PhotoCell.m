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
@property (nonatomic, strong) UIView *selectedView;

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
    [self.cellImageView setImageWithURL:[NSURL URLWithString:photo.thumbnailImage.urlString] placeholderImage:nil];
}

- (void)setSelected:(BOOL)selected {
    if (self.isSelected!=selected) {
        [super setSelected:selected];
        [self showSelectedView:selected];
    }
}

- (void)showSelectedView:(BOOL)selected {
    if (selected) {
        if (!self.selectedView) {
            self.selectedView = [[UIView alloc] initWithFrame:self.bounds];
            [self.selectedView setBackgroundColor:[UIColor whiteColor]];
            [self.selectedView setAlpha:0.5];
            [self.contentView addSubview:self.selectedView];
        }
    } else {
        if (self.selectedView) {
            [self.selectedView removeFromSuperview];
            self.selectedView = nil;
        }
    }
}

@end
