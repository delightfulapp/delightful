//
//  PhotosSectionHeaderView.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosSectionHeaderView.h"

#import "PureLayout.h"

#import "LocationManager.h"

#import "UIColor+Additionals.h"

#import "UIView+Additionals.h"

@interface PhotosSectionHeaderView ()

@property (nonatomic, weak) UIView *gestureView;

@property (nonatomic, strong) NSLayoutConstraint *rightTitleConstraint;

@end

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
    
    [self setupConstrains];
    
    [self.titleLabel setTextAlignment:NSTextAlignmentRight];
    [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.titleLabel setNumberOfLines:2];
    
    [self insertSubview:self.blurView atIndex:0];
    [self.titleLabel setTextColor:[UIColor redColor]];
    
    [self setUserInteractionEnabled:YES];
    
    [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    
    [self setupGestureViewConstrains];
}

- (void)prepareForReuse {
    [self.titleLabel setText:nil];
    
    [self.rightTitleConstraint setConstant:0];
}

- (void)setupConstrains {
    self.rightTitleConstraint = [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:0 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.blurView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
    [self.blurView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self.blurView autoCenterInSuperview];
   
}

- (void)setupGestureViewConstrains {
    [self.gestureView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
    [self.gestureView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self.gestureView autoCenterInSuperview];
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
    [self adjustTitleLabelRightConstraint];
}

- (void)setLocationString:(NSString *)location {
    if (location) {
        [self.titleLabel setAttributedText:[self attributedStringWithTitle:self.titleLabelText location:location]];
    } else {
        [self.titleLabel setAttributedText:[self attributedStringWithTitle:self.titleLabelText location:nil]];
    }
    [self adjustTitleLabelRightConstraint];
}

- (void)adjustTitleLabelRightConstraint {
    if (self.titleLabel.text.length > 0) [self.rightTitleConstraint setConstant:-10];
    else [self.rightTitleConstraint setConstant:0];
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
        [_titleLabel setUserInteractionEnabled:YES];
    }
    return _titleLabel;
}

- (UIView *)blurView {
    if (!_blurView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [effectView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:effectView];
        //[effectView setAlpha:0];
        _blurView = effectView;
    }
    return _blurView;
}

- (UIView *)gestureView {
    if (!_gestureView) {
        _gestureView = [self addSubviewClass:[UIView class]];
        [_gestureView setBackgroundColor:[UIColor clearColor]];
        [_gestureView setUserInteractionEnabled:YES];
    }
    return _gestureView;
}

#pragma mark - Gestures

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [self.gestureView addGestureRecognizer:gestureRecognizer];
}

- (NSArray *)gestureRecognizers {
    return [self.gestureView gestureRecognizers];
}

@end
