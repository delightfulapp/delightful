//
//  LeftViewController.h
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftViewController : UIViewController

- (id)initWithRootViewController:(id)viewController;

@property (nonatomic, strong, readonly) id rootViewController;

@end
