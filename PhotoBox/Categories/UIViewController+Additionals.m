//
//  UIViewController+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIViewController+Additionals.h"

#define kLoadingViewTag 87261

@implementation UIViewController (Additionals)

- (void)showLoadingView:(BOOL)show atBottomOfScrollView:(BOOL)bottom {
    if ([self isKindOfClass:[UICollectionViewController class]]) {
        UICollectionViewController *cv = (UICollectionViewController *)self;
        if (show) {
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[cv.collectionView viewWithTag:kLoadingViewTag];
            if (!activity) {
                activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activity setTag:kLoadingViewTag];
                [cv.collectionView addSubview:activity];
            }
            CGSize contentSize = cv.collectionView.contentSize;
            [activity setCenter:CGPointMake(contentSize.width/2, contentSize.height+CGRectGetHeight(activity.frame)/2+10)];
            [activity startAnimating];
            UIEdgeInsets inset = cv.collectionView.contentInset;
            [cv.collectionView setContentInset:UIEdgeInsetsMake(inset.top, inset.left, inset.bottom + CGRectGetHeight(activity.frame)*2, inset.right)];
        } else {
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[cv.collectionView viewWithTag:kLoadingViewTag];
            [activity stopAnimating];
            [activity removeFromSuperview];
        }
    }
    
}

@end
