//
//  UIViewController+Additionals.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Additionals)

- (void)showLoadingView:(BOOL)show atBottomOfScrollView:(BOOL)bottom;

- (void)openActivityPickerForImage:(UIImage *)image;

- (void)toggleNavigationBarHidden;

- (void)hideNavigationBar;

@end
