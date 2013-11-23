//
//  DelightfulTabBar.m
//  Delightful
//
//  Created by Nico Prananta on 11/23/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "DelightfulTabBar.h"

@implementation DelightfulTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.barTintColor = [UIColor colorWithRed:0.116 green:0.111 blue:0.131 alpha:1.000];
    self.barStyle = UIBarStyleDefault;
    self.backgroundColor = [UIColor colorWithRed:41.f/255.f green:39.f/255.f blue:46.f/255.f alpha:1];
    self.backgroundImage = nil;
    self.selectedImageTintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
}

@end
