//
//  LoginViewController.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/5/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

- (IBAction)tapOnImage:(id)sender;
- (IBAction)tryTapped:(id)sender;

@end
