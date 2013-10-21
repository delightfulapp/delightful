//
//  NPRNotificationView.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/20/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "NPRNotificationView.h"

#import "UIView+Additionals.h"

@interface NPRNotificationView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *rightAccessoryView;
@property (nonatomic, assign) NPRNotificationAccessoryType accessoryType;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) NPRNotificationType type;

@end

@implementation NPRNotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat margin = 10;
    
    // position the image
    if (self.imageView.image) {
        [self.imageView setWidth:height*0.7 height:height*0.7];
        [self.imageView setPositionFromEdge:MNCUIViewLeftEdge margin:margin];
        [self.imageView setPositionInCenterYOfSuperview];
    } else {
        [self.imageView setFrame:CGRectZero];
    }
    
    // position the right accessory view
    if (self.rightAccessoryView) {
        [self.rightAccessoryView setWidth:height*0.8 height:height*0.8];
        [self.rightAccessoryView setPositionFromEdge:MNCUIViewRightEdge margin:margin];
        [self.rightAccessoryView setPositionInCenterYOfSuperview];
    }
    
    // position the text
    CGFloat width = CGRectGetWidth(self.frame);
    if (self.imageView.image) {
        width -= CGRectGetWidth(self.imageView.frame) + margin;
        
    }
    if (self.rightAccessoryView) {
        width -= CGRectGetWidth(self.rightAccessoryView.frame) + margin;
    }
    width -= 2 * margin;
    [self.textLabel fitToWidth:width];
    
    [self.textLabel setPositionInCenterYOfSuperview];
    [self.textLabel setOriginX:CGRectGetMaxX(self.imageView.frame)+margin];
}

- (void)setType:(NPRNotificationType)type {
    _type = type;
    [self setBackgroundColor:[self colorForType:type]];
}

- (UIImage *)imageForType:(NPRNotificationType)type {
    NSString *image = nil;
    switch (type) {
        case NPRNotificationTypeError:
            image = @"npr_notification_image_error.png";
            break;
        case NPRNotificationTypeSuccess:
            image = @"npr_notification_image_success.png";
            break;
        case NPRNotificationTypeWarning:
            image = @"npr_notification_image_warning.png";
            break;
        case NPRNotificationTypeNone:
            image = nil;
            break;
        default:
            break;
    }
    return [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIColor *)colorForType:(NPRNotificationType)type {
    UIColor *color;
    switch (type) {
        case NPRNotificationTypeNone:
            color = [UIColor colorWithRed:0.218 green:0.457 blue:0.857 alpha:1.000];
            break;
        case NPRNotificationTypeWarning:
            color = [UIColor colorWithRed:0.809 green:0.577 blue:0.309 alpha:1.000];
            break;
        case NPRNotificationTypeError:
            color = [UIColor colorWithRed:1.000 green:0.190 blue:0.200 alpha:1.000];
            break;
        case NPRNotificationTypeSuccess:
            color = [UIColor colorWithRed:0.411 green:0.716 blue:0.377 alpha:1.000];
            break;
        default:
            break;
    }
    return color;
}

- (void)setString:(NSString *)string {
    [self.textLabel setText:string];
}

- (void)setAccessoryType:(NPRNotificationAccessoryType)accessoryType {
    BOOL shouldUpdate = NO;
    if (_accessoryType!=accessoryType) {
        shouldUpdate = YES;
        _accessoryType = accessoryType;
        
    }
    switch (_accessoryType) {
        case NPRNotificationAccessoryTypeNone:
            if (shouldUpdate || !self.accessoryView) {
                if (self.rightAccessoryView) {
                    [self.rightAccessoryView removeFromSuperview];
                }
                [self setRightAccessoryView:nil];
            }
            break;
        case NPRNotificationAccessoryTypeActivityView:
            if (shouldUpdate || !self.accessoryView) {
                UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [self setRightAccessoryView:indicatorView];
                [indicatorView startAnimating];
            }
            break;
        case NPRNotificationAccessoryTypeCloseButton:
            if (shouldUpdate || !self.accessoryView) {
                UIButton *closeButton = [[UIButton alloc] init];
                [closeButton setImage:[[UIImage imageNamed:@"npr_notification_image_close.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [closeButton setBackgroundColor:[UIColor clearColor]];
                [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self setRightAccessoryView:closeButton];
            }
            break;
        default:
            break;
    }
}

- (void)setAccessoryView:(UIView *)accessoryView {
    if (_accessoryView != accessoryView) {
        _accessoryView = accessoryView;
        [self setRightAccessoryView:_accessoryView];
    }
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
    }
    if (!_image) {
        _image = [self imageForType:self.type];
    }
    [self.imageView setImage:_image];
}

- (void)setRightAccessoryView:(UIView *)rightAccessoryView {
    if (_rightAccessoryView != rightAccessoryView) {
        _rightAccessoryView = rightAccessoryView;
        if (_rightAccessoryView) {
            if (!_rightAccessoryView.superview) {
                [self addSubview:_rightAccessoryView];
            }
        }
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageView setClipsToBounds:YES];
        [_imageView setTintColor:[UIColor whiteColor]];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        [_textLabel setBackgroundColor:[UIColor clearColor]];
        [_textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        [_textLabel setTextColor:[UIColor whiteColor]];
        [_textLabel setNumberOfLines:2];
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

#pragma mari - Button

- (void)closeButtonTapped:(UIButton *)button {
    [[NPRNotificationManager sharedManager] hideNotification];
}

@end
