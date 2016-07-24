//
//  UploadReloadView.m
//  Delightful
//
//  Created by  on 7/26/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "UploadReloadView.h"

#import "PureLayout.h"

@interface UploadReloadView ()

@property (nonatomic, weak) UIButton *reloadButton;

@property (nonatomic, weak) UIButton *cancelButton;

@property (nonatomic, weak) UILabel *failLabel;

@end

@implementation UploadReloadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.500]];
        
        [self.cancelButton autoSetDimension:ALDimensionWidth toSize:44];
        [self.cancelButton autoSetDimension:ALDimensionHeight toSize:44];
        [self.reloadButton autoSetDimension:ALDimensionWidth toSize:44];
        [self.reloadButton autoSetDimension:ALDimensionHeight toSize:44];
        [self.cancelButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-10];
        [self.cancelButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self];
        [self.reloadButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.cancelButton withOffset:-20];
        [self.reloadButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self];
        [self.failLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:15];
        [self.failLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.cancelButton];
    }
    return self;
}


- (UIButton *)reloadButton {
    if (!_reloadButton) {
        UIButton *reloadButton = [[UIButton alloc] init];
        [reloadButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [reloadButton setImage:[[UIImage imageNamed:@"refresh.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [reloadButton setTintColor:[UIColor whiteColor]];
        [self addSubview:reloadButton];
        _reloadButton = reloadButton;
    }
    return _reloadButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        UIButton *cancelButton = [[UIButton alloc] init];
        [cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cancelButton setImage:[[UIImage imageNamed:@"npr_notification_image_close.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [cancelButton setTintColor:[UIColor whiteColor]];
        [self addSubview:cancelButton];
        _cancelButton = cancelButton;
    }
    return _cancelButton;
}

- (UILabel *)failLabel {
    if (!_failLabel) {
        UILabel *label = [[UILabel alloc] init];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:NSLocalizedString(@"Upload failed", nil)];
        
        [self addSubview:label];
        _failLabel = label;
    }
    return _failLabel;
}

@end
