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

@end

@interface ShowFullScreenPhotosAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@end
