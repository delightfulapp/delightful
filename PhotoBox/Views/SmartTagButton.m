//
//  SmartTagButton.m
//  Delightful
//
//  Created by  on 12/18/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "SmartTagButton.h"

@implementation SmartTagButton

- (void)setTagState:(TagState)tagState {
    _tagState = tagState;
    
    if (_tagState == TagStateSelected) {
        [self setBackgroundColor:[UIColor colorWithRed:0.255 green:0.529 blue:0.835 alpha:1.000]];
    } else {
        [self setBackgroundColor:[UIColor colorWithWhite:0.779 alpha:1.000]];
    }
}

@end
