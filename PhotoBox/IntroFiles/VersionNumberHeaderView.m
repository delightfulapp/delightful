//
//  VersionNumberHeaderView.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/24/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "VersionNumberHeaderView.h"

@implementation VersionNumberHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (NSString *)text {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

- (NSString *)fontName {
    return @"HelveticaNeue-Bold";
}

@end
