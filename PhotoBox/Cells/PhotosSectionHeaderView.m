//
//  PhotosSectionHeaderView.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosSectionHeaderView.h"

#import <UIView+AutoLayout.h>

#import "LocationManager.h"

#import <AMBlurView.h>

#import "UIColor+Additionals.h"

#import "UIView+Additionals.h"

@implementation PhotosSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup {
    [self listenToLocationNotification:!self.hideLocation];
    
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-10];
    NSLayoutConstraint * constraint = [self.titleLabel autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [constraint setPriority:100];
    [self.locationLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:10];
    [self.locationLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel];
    [self.blurView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
    [self.blurView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self.blurView autoCenterInSuperview];
    
    [self.locationLabel setText:nil];
    [self.titleLabel setTextAlignment:NSTextAlignmentRight];
    [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.titleLabel setNumberOfLines:2];
    
    [self.blurView setBlurTintColor:[UIColor whiteColor]];
    [self insertSubview:self.blurView atIndex:0];
    [self.titleLabel setTextColor:[UIColor redColor]];
    [self.locationLabel setTextColor:[[UIColor redColor] lighterColor]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)locationDidFetched:(NSNotification *)notification {
    NSNumber *section = [(NSDictionary *)notification.object objectForKey:@"section"];
    if ([section integerValue] == self.section) {
        CLPlacemark *placemark = [(NSDictionary *)notification.object objectForKey:@"placemark"];
        [self setLocation:placemark];
    }
}

- (void)setLocation:(CLPlacemark *)placemark {
    if (placemark) {
        NSString *location = placemark.locality;
        if (!location) location = placemark.name;
        location = [NSString stringWithFormat:@"%@, %@", location, placemark.country];
        [self.titleLabel setAttributedText:[self attributedStringWithTitle:self.titleLabelText location:location]];
    } else {
        [self.titleLabel setAttributedText:[self attributedStringWithTitle:self.titleLabelText location:nil]];
    }
}

- (NSAttributedString *)attributedStringWithTitle:(NSString *)title location:(NSString *)location {
    NSString *text = title;
    if (location) {
        text = [NSString stringWithFormat:@"%@\n%@", text, location];
    }
    
    if (text && text.length > 0) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
        [string addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1] range:[text rangeOfString:title]];
        if (location) {
            NSRange locationRange = [text rangeOfString:location];
            [string addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:8] range:locationRange];
            [string addAttribute:NSForegroundColorAttributeName value:[[UIColor redColor] lighterColor] range:locationRange];
        }
        return string;
    }
    
    return nil;
}

- (void)setHideLocation:(BOOL)hideLocation {
    _hideLocation = hideLocation;
    [self listenToLocationNotification:!_hideLocation];
}

- (void)listenToLocationNotification:(BOOL)listen {
    if (!listen) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFetched:) name:PhotoBoxLocationPlacemarkDidFetchNotification object:nil];
    }
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [self addSubviewClass:[UILabel class]];
    }
    return _titleLabel;
}

- (UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [self addSubviewClass:[UILabel class]];
    }
    return _locationLabel;
}

- (AMBlurView *)blurView {
    if (!_blurView) {
        _blurView = [self addSubviewClass:[AMBlurView class]];
    }
    return _blurView;
}

@end
