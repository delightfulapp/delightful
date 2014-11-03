//
//  LoginViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/5/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "LoginViewController.h"

#import "ConnectionManager.h"
#import "NSString+Additionals.h"
#import "UIView+Additionals.h"
#import "LoginWebViewViewController.h"
#import "FallingTransitioningDelegate.h"
#import "UIViewControllerModalDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController () <UIViewControllerModalDelegate>

@property (nonatomic, strong) FallingTransitioningDelegate *fallingTransitioningDelegate;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    [self.infoButton setImage:[[UIImage imageNamed:@"info.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.backgroundImageView addTransparentGradientWithStartColor:[UIColor blackColor]];
    
    [self.infoButton setImage:[[UIImage imageNamed:@"info.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoButtonTapped:)];
    [self.infoButton setUserInteractionEnabled:YES];
    [self.infoButton addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapOnImage:(id)sender {
    [self.view endEditing:YES];
}

- (void)tryTapped:(id)sender {
    [[ConnectionManager sharedManager] connectAsTester];
}

- (void)infoButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://trovebox.com"]];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (!textField.text || textField.text.length == 0) {
#ifdef IS_FEZZ
        [textField setText:@"http://192.168.0.200"];
#else
       [textField setText:@".trovebox.com"];
#endif
        
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@".trovebox.com"]) {
        UITextPosition *newCursorPosition = [textField positionFromPosition:textField.beginningOfDocument offset:0];
        UITextRange *newSelectedRange = [textField textRangeFromPosition:newCursorPosition toPosition:newCursorPosition];
        [textField setSelectedTextRange:newSelectedRange];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text isValidURL]) {
        [textField setEnabled:NO];
        [self.activityView startAnimating];
        [self.view endEditing:YES];
        NSURL *url = [[ConnectionManager sharedManager] startOAuthAuthorizationWithServerURL:[textField.text stringWithHttpSchemeAddedIfNeeded]];
        LoginWebViewViewController *loginWebView = [[LoginWebViewViewController alloc] init];
        [loginWebView setViewControllerDelegate:self];
        [loginWebView setInitialURL:url];
        if (!self.fallingTransitioningDelegate) {
            FallingTransitioningDelegate *falling = [[FallingTransitioningDelegate alloc] init];
            self.fallingTransitioningDelegate = falling;
        }
        
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:loginWebView];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [self presentViewController:navCon animated:YES completion:^{
            [textField setEnabled:YES];
            [self.activityView stopAnimating];
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Server", nil) message:NSLocalizedString(@"Please provide a valid host URL", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
    }
    return YES;
}

#pragma mark - UIViewControllerModalDelegate

- (void)viewController:(id)viewController didTapDismissButton:(id)sender {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

@end
