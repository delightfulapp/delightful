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
@property (weak, nonatomic) IBOutlet UIImageView *infoButton;
@property (weak, nonatomic) IBOutlet UITextField *serverField;
@property (weak, nonatomic) IBOutlet UIView *serverView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serverViewCenterYConstraint;
@property (weak, nonatomic) IBOutlet UILabel *delightfulTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *delightfulSubtitleLabel;

- (IBAction)tapOnImage:(id)sender;
- (IBAction)tryTapped:(id)sender;

@end
