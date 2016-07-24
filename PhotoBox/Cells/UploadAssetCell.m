//
//  UploadAssetCell.m
//  Delightful
//
//  Created by Nico Prananta on 6/22/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "UploadAssetCell.h"
#import "DAProgressOverlayView.h"
#import "DLFAsset.h"
#import "NSAttributedString+DelighftulFonts.h"

@interface UploadAssetCell ()

@property (nonatomic, strong) DAProgressOverlayView *uploadingView;
@property (nonatomic, assign) float uploadProg;
@property (nonatomic, strong) UILabel *reloadButton;

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
        
        [self setUploadProgress:0];
    }
}

- (void)prepareForReuse {
    if (self.uploadProg == 1) {
        [self.uploadingView removeFromSuperview];
        self.uploadingView = nil;
    }
}


- (void)setUploadProgress:(float)progress {
    if (!self.uploadingView) {
        self.uploadingView = [[DAProgressOverlayView alloc] initWithFrame:self.contentView.bounds];
        [self.uploadingView setOverlayColor:[UIColor colorWithWhite:0.000 alpha:0.760]];
        [self.contentView addSubview:self.uploadingView];
    }
    
    [self.contentView bringSubviewToFront:self.uploadingView];
    
    _uploadProg = progress;
    
    [self.uploadingView setProgress:progress];
}

- (void)removeUploadProgress {
    [self.uploadingView removeFromSuperview];
    self.uploadingView = nil;
}

- (void)showReloadButton:(BOOL)show {
    if (show) {
        if (!self.reloadButton) {
            self.reloadButton = [[UILabel alloc] init];
            [self.contentView addSubview:self.reloadButton];
            [self.reloadButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
            NSMutableAttributedString *reloadString = [[NSAttributedString symbol:dlf_icon_spinner size:40] mutableCopy];
            [reloadString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, reloadString.string.length)];
            [self.reloadButton setAttributedText:reloadString];
            [self.reloadButton sizeToFit];
            self.reloadButton.center = CGPointMake(CGRectGetWidth(self.contentView.frame)/2, CGRectGetHeight(self.contentView.frame)/2);
            [self.contentView bringSubviewToFront:self.reloadButton];
        }
        [self.reloadButton setHidden:NO];
    } else {
        [self.reloadButton setHidden:YES];
    }
}

@end
