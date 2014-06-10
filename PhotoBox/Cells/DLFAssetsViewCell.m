//
//  DLFAssetsViewCell.m
//  Delightful
//
//  Created by Nico Prananta on 6/10/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DLFAssetsViewCell.h"

#import <UIColor+Crayola.h>

@interface DLFAssetsViewCell ()

@property (nonatomic, strong) UIImageView *uploadedView;

@end

@implementation DLFAssetsViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setUploaded:(BOOL)uploaded {
    _uploaded = uploaded;
    
    [self showUploadedView:_uploaded];
}

- (void)showUploadedView:(BOOL)show {
    if (show) {
        if (!self.uploadedView) {
            self.uploadedView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"uploaded.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [self.uploadedView setBackgroundColor:[UIColor clearColor]];
            [self.uploadedView setTintColor:[UIColor crayolaYellowSunshineColor]];
            [self.contentView addSubview:self.uploadedView];
        }
        self.uploadedView.frame = ({
            CGRect frame = self.uploadedView.frame;
            frame.origin.x = CGRectGetWidth(self.contentView.frame) - frame.size.width - 5;
            frame.origin.y = CGRectGetHeight(self.contentView.frame) - frame.size.height - 5;
            frame;
        });
    } else {
        [self.uploadedView removeFromSuperview];
        self.uploadedView = nil;
    }
}

@end
