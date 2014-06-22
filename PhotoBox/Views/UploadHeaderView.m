//
//  UploadHeaderView.m
//  Delightful
//
//  Created by Nico Prananta on 6/22/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "UploadHeaderView.h"

#import <UIView+AutoLayout.h>

#import "UIView+Additionals.h"

@interface UploadHeaderView ()

@property (nonatomic, weak) UILabel *uploadingLabel;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;

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
    [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
        [self.uploadingLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:10];
        [self.uploadingLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.uploadingLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.indicatorView withOffset:-10 relation:NSLayoutRelationLessThanOrEqual];
        [self.indicatorView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-10];
        [self.indicatorView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    }];
    
    [self.uploadingLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)setNumberOfUploads:(NSInteger)numberOfUploads {
    [self.uploadingLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Uploading %1$d %2$@ ...", nil), numberOfUploads, numberOfUploads==1?NSLocalizedString(@"photo", nil):NSLocalizedString(@"photos", nil)]];
    if (numberOfUploads > 0) {
        [self.indicatorView startAnimating];
    }
}

#pragma mark - Getters

- (UILabel *)uploadingLabel {
    if (!_uploadingLabel) {
        _uploadingLabel = [self addSubviewClass:[UILabel class]];
        [_uploadingLabel setBackgroundColor:[UIColor clearColor]];
        [_uploadingLabel setFont:[UIFont systemFontOfSize:12]];
    }
    return _uploadingLabel;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [act setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:act];
        _indicatorView = act;
    }
    return _indicatorView;
}

@end
