//
//  PhotoZoomableCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoZoomableCell.h"

@implementation PhotoZoomableCell 

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
    [self.cellImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView setMaximumZoomScale:2];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.cellImageView;
}

@end
