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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFetched:) name:PhotoBoxLocationPlacemarkDidFetchNotification object:nil];
    
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-10];
    [self.locationLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:10];
    [self.locationLabel setText:nil];
}

- (void)locationDidFetched:(NSNotification *)notification {
    NSNumber *section = [(NSDictionary *)notification.object objectForKey:@"section"];
    if ([section integerValue] == self.section) {
        CLPlacemark *placemark = [(NSDictionary *)notification.object objectForKey:@"placemark"];
        [self setLocation:placemark];
    }
}

- (void)setLocation:(CLPlacemark *)placemark {
    
    NSString *location = placemark.locality;
    if (!location) location = placemark.name;
    [self.locationLabel setText:[NSString stringWithFormat:@"%@, %@", location, placemark.country]];
}

@end
