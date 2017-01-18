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
    [super awakeFromNib];
    [self.infoButton setImage:[[UIImage imageNamed:@"info.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	    
    [self.infoButton setImage:[[UIImage imageNamed:@"info.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoButtonTapped:)];
    [self.infoButton setUserInteractionEnabled:YES];
    [self.infoButton addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppearNotification:) name:UIKeyboardDidShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappearNotification:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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
    [[ConnectionManager sharedManager] connectAsGuest:[NSURL URLWithString:@"http://current.trovebox.com"]];
}

- (void)infoButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://trovebox.com"]];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (!textField.text || textField.text.length == 0) {
       [textField setText:@"https://"];
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    void (^errorBlock)() = ^void() {
         [textField setEnabled:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Server", nil) message:NSLocalizedString(@"Please provide a valid host URL or IP address. Example: https://trovebox.com. Also make sure this device is connected to the internet.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
        [self.activityView stopAnimating];
    };

    if ([textField.text isValidURL]) {
        [self restoreKeyboardAndTitleLabel];
        [textField setEnabled:NO];
        [self.activityView startAnimating];
        [self.view endEditing:YES];
        
        NSString *serverURLString = [textField.text stringWithHttpSchemeAddedIfNeeded];
        NSURL *serverURL = [NSURL URLWithString:serverURLString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serverURL];
        [request setHTTPMethod:@"HEAD"];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 10;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    errorBlock();
                } else {
                    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
                    if (resp.statusCode == 200) {
                        NSURL *url = [[ConnectionManager sharedManager] startOAuthAuthorizationWithServerURL:serverURLString];
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
                        errorBlock();
                    }
                }
            });
        }];
        [dataTask resume];
    } else {
        errorBlock();
    }
    return YES;
}

#pragma mark - UIViewControllerModalDelegate

- (void)viewController:(id)viewController didTapDismissButton:(id)sender {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

#pragma mark - Keyboards

- (void)keyboardDidAppearNotification:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect rect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectIsNull(CGRectIntersection(rect, self.serverView.frame))) {
        CGRect frame = self.serverView.frame;
        CGFloat newOrigin = rect.origin.y - frame.size.height - 10;
        CGFloat diff = self.serverView.center.y - newOrigin;
        self.serverViewCenterYConstraint.constant = diff;
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.delightfulTitleLabel setAlpha:0];
            [self.delightfulSubtitleLabel setAlpha:0];
            [self.view layoutIfNeeded];
        } completion:nil];
        
    }
}

- (void)keyboardWillDisappearNotification:(NSNotification *)notification {
    if (self.serverViewCenterYConstraint.constant != 0) {
        [self restoreKeyboardAndTitleLabel];
    }
}

- (void)restoreKeyboardAndTitleLabel {
    self.serverViewCenterYConstraint.constant = 0;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.delightfulTitleLabel setAlpha:1];
        [self.delightfulSubtitleLabel setAlpha:1];
        [self.view layoutIfNeeded];
    } completion:nil];
}

@end
