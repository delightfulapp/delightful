//
//  UICollectionView+Additionals.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UICollectionViewCell+Additionals.h"

@implementation UICollectionViewCell (Additionals)

- (id)addSubviewToContentViewWithClass:(Class)class {
    UIView *view = [[class alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:view];
    return view;
}

@end
