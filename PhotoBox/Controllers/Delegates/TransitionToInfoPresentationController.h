//
//  TransitionToInfoPresentationController.h
//  Delightful
//
//  Created by  on 10/4/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TransitionToInfoPresentationControllerPresentingDelegate <NSObject>

- (void)willAnimateAlongTransitionToPresentInfoController:(id)presentationController;
- (void)animateAlongTransitionToPresentInfoController:(id)presentationController;
- (void)dismissAlongTransitionToInfoController:(id)presentationController;
- (void)didFinishDismissAnimationFromInfoControllerPresentationController:(id)presentationController;

@end

@interface TransitionToInfoPresentationController : UIPresentationController

@end
