//
//  UIViewControllerModalDelegate.h
//  Delightful
//
//  Created by Nico Prananta on 5/25/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIViewControllerModalDelegate <NSObject>

@optional
- (void)viewController:(id)viewController didTapDismissButton:(id)sender;

@end
