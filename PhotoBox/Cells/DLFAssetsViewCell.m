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
            self.uploadedView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"uploadedmark.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [self.uploadedView setBackgroundColor:[UIColor clearColor]];
            [self.uploadedView setTintColor:[UIColor whiteColor]];
            [self.uploadedView.layer setShadowColor:[[UIColor blackColor] CGColor]];
            [self.uploadedView.layer setShadowOffset:CGSizeMake(0, 1)];
            [self.uploadedView.layer setShadowOpacity:0.7];
            [self.uploadedView.layer setShadowRadius:1];
            [self.uploadedView.layer setShouldRasterize:YES];
            [self.contentView addSubview:self.uploadedView];
        }
        self.uploadedView.frame = ({
            CGRect frame = self.uploadedView.frame;
            frame.origin.x = CGRectGetWidth(self.contentView.frame) - frame.size.width + 2;
            frame.origin.y = CGRectGetHeight(self.contentView.frame) - frame.size.height + 4;
            frame;
        });
    } else {
        [self.uploadedView removeFromSuperview];
        self.uploadedView = nil;
    }
}

@end
