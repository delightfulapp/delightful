//
//  UploadHeaderView.m
//  Delightful
//
//  Created by Nico Prananta on 6/22/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "UploadHeaderView.h"

#import "PureLayout.h"

#import "UIView+Additionals.h"

@interface UploadHeaderView ()

@property (nonatomic, weak) UILabel *uploadingLabel;

@end

@implementation UploadHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
//    [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
//        [self.uploadingLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
//        [self.uploadingLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
//        [self.uploadingLabel autoCenterInSuperview];
//    }];
    
    [self setBackgroundColor:[UIColor albumsBackgroundColor]];
}

- (void)setNumberOfUploads:(NSInteger)numberOfUploads {
    if (numberOfUploads == 0) {
        [self.uploadingLabel setHidden:YES];
    } else {
        [self.uploadingLabel setHidden:NO];
        [self.uploadingLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Uploading %1$d %2$@ ...", nil), numberOfUploads, numberOfUploads==1?NSLocalizedString(@"photo", nil):NSLocalizedString(@"photos", nil)]];
    }
}

#pragma mark - Getters

- (UILabel *)uploadingLabel {
    if (!_uploadingLabel) {
        _uploadingLabel = [self addSubviewClass:[UILabel class]];
        [_uploadingLabel setBackgroundColor:[UIColor clearColor]];
        [_uploadingLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [_uploadingLabel setAdjustsFontSizeToFitWidth:YES];
        [_uploadingLabel setTextColor:[UIColor whiteColor]];
        [_uploadingLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _uploadingLabel;
}

@end
