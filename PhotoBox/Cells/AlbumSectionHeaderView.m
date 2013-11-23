//
//  AlbumSectionHeaderView.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumSectionHeaderView.h"

#import <UIView+AutoLayout.h>

#import <AMBlurView.h>

#import "UIView+Additionals.h"

#import "UIViewController+DelightfulViewControllers.h"

@interface AlbumSectionHeaderView ()

@property (nonatomic, weak) UIImageView *arrowImage;

@end

@implementation AlbumSectionHeaderView

- (void)setup {
    [super setup];
    
    [self.titleLabel setHidden:YES];
    [self.locationLabel setTextColor:[UIColor whiteColor]];
    
}

- (UIImageView *)arrowImage {
    if (!_arrowImage) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"right.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setTintColor:[UIColor whiteColor]];
        [self addSubview:imageView];
        _arrowImage = imageView;
    }
    return _arrowImage;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [self addSubviewClass:[UIView class]];
        [_lineView setBackgroundColor:[UIColor colorWithRed:0.297 green:0.284 blue:0.335 alpha:1.000]];
        [_lineView.layer setShadowColor:[UIColor blackColor].CGColor];
        [_lineView.layer setShadowOffset:CGSizeMake(0, -0.5)];
        [_lineView.layer setShadowOpacity:1];
        [_lineView.layer setShadowRadius:0];
    }
    return _lineView;
}

- (void)setupConstrains {
    CGFloat visibleWidth = [UIViewController leftViewControllerVisibleWidth];
    CGFloat offset = visibleWidth - CGRectGetWidth(self.frame) - 20;
    [self.arrowImage autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.arrowImage autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:offset];
    
    [self.locationLabel autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.locationLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:10];
    
    [self.titleLabel autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:offset];
    
    [self.blurView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
    [self.blurView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self.blurView autoCenterInSuperview];
    
    [self.lineView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-20];
    [self.lineView autoSetDimension:ALDimensionHeight toSize:0.5];
    [self.lineView autoCenterInSuperviewAlongAxis:ALAxisVertical];
    [self.lineView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self];
}

#pragma mark - Setters

- (void)setText:(NSString *)text {
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor blackColor]];
    [shadow setShadowOffset:CGSizeMake(0, -1)];
    [shadow setShadowBlurRadius:0];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{NSShadowAttributeName: shadow}];
    
    [self.locationLabel setAttributedText:attributedString];
}

@end
