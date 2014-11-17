//
//  ShowFullScreenPhotosAnimatedTransitioning.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CustomAnimationTransitionFromViewControllerDelegate <NSObject>

- (UIImage *)imageToAnimate;
- (CGRect)startRectInContainerView:(UIView *)view;
- (CGRect)endRectInContainerView:(UIView *)view;
- (UIView *)destinationViewOnDismiss;
- (UIView *)viewToAnimate;

@end

@interface ShowFullScreenPhotosAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) UINavigationControllerOperation operation;

@property (nonatomic, strong) UIViewController<CustomAnimationTransitionFromViewControllerDelegate> *presentingViewController;

@end
