//
//  AlbumRowCell.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "DelightfulRowCell.h"

#import <QuartzCore/QuartzCore.h>

#import <UIView+AutoLayout.h>

#import "UIView+Additionals.h"

@interface DelightfulRowCell ()

@property (nonatomic, weak) UIView *lineView;

@end

@implementation DelightfulRowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [self.cellImageView setBackgroundColor:[UIColor colorWithWhite:0.905 alpha:1.000]];
    [self.cellImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cellImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.cellImageView setClipsToBounds:YES];
    
    [self.cellImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView withOffset:-20];
    [self.cellImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self.cellImageView];
    [self.cellImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset:10];
    [self.cellImageView autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    
    [self.textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.cellImageView withOffset:10];
    [self.textLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-10];
    [self.textLabel autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    
    [self.lineView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withOffset:-20];
    [self.lineView autoSetDimension:ALDimensionHeight toSize:1];
    [self.lineView autoCenterInSuperviewAlongAxis:ALAxisVertical];
    [self.lineView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView];
    
    [self.contentView bringSubviewToFront:self.textLabel];
    
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
    [self.textLabel setTextColor:[UIColor blackColor]];
}

- (void)layoutSubviews {
    [self.cellImageView.layer setCornerRadius:CGRectGetWidth(self.cellImageView.frame)/2];
}

#pragma mark - Getters

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [self.contentView addSubviewClass:[UILabel class]];
    }
    return _textLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [self.contentView addSubviewClass:[UIView class]];
        [_lineView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]];
    }
    return _lineView;
}

@end
