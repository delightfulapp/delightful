//
//  LoginWebViewViewController.h
//  Delightful
//
//  Created by Nico Prananta on 5/22/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewControllerModalDelegate.h"

@interface LoginWebViewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (nonatomic, strong) NSURL *initialURL;

@property (nonatomic, weak) id<UIViewControllerModalDelegate>viewControllerDelegate;

@end
