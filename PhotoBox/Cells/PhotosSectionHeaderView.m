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

@implementation PhotosSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self listenToLocationNotification:!self.hideLocation];
    
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-10];
    [self.locationLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:10];
    [self.locationLabel setText:nil];
    [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.titleLabel setNumberOfLines:2];
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
        [self.titleLabel setText:[NSString stringWithFormat:@"%@\n%@", self.titleLabelText, location]];
    } else {
        [self.titleLabel setText:self.titleLabelText];
    }
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

@end
