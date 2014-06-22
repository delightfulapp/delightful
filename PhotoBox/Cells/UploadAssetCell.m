//
//  UploadAssetCell.m
//  Delightful
//
//  Created by Nico Prananta on 6/22/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "UploadAssetCell.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface UploadAssetCell ()

@property (nonatomic, strong) UIView *uploadingView;

@property (nonatomic, assign) float uploadProg;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation UploadAssetCell

@synthesize item = _item;

- (void)setup {
    [super setup];
    
    [self setUploadProgress:0];
}

- (void)setItem:(id)item {
    if (_item != item) {
        _item = item;
        
        ALAsset *asset = (ALAsset *)_item;
        [self.cellImageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    }
}

- (void)prepareForReuse {
    [self.uploadingView removeFromSuperview];
    self.uploadingView = nil;
    [self.indicatorView removeFromSuperview];
    self.indicatorView = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setUploadProgress:self.uploadProg];
}


- (void)setUploadProgress:(float)progress {
    if (!self.uploadingView) {
        self.uploadingView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [self.uploadingView setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.780]];
        [self.contentView addSubview:self.uploadingView];
    }
    
    if (!self.indicatorView) {
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.indicatorView setCenter:CGPointMake(CGRectGetWidth(self.contentView.frame)/2, CGRectGetHeight(self.contentView.frame)/2)];
        [self.contentView addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
    }
    
    [self.contentView bringSubviewToFront:self.uploadingView];
    [self.contentView bringSubviewToFront:self.indicatorView];
    
    _uploadProg = progress;
    
    self.uploadingView.frame = ({
        CGRect frame = self.uploadingView.frame;
        frame.size.width = self.contentView.frame.size.width;
        frame.size.height = (1-progress) * self.contentView.frame.size.height;
        frame.origin.x = 0;
        frame.origin.y = CGRectGetHeight(self.contentView.frame) - frame.size.height;
        frame;
    });
}

- (void)removeUploadProgress {
    [self.uploadingView removeFromSuperview];
    [self.indicatorView removeFromSuperview];
    self.uploadingView = nil;
    self.indicatorView = nil;
}

@end
