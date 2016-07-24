//
//  LoginWebViewViewController.m
//  Delightful
//
//  Created by Nico Prananta on 5/22/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "LoginWebViewViewController.h"
#import "ConnectionManager.h"
#import "OnePasswordExtension.h"

@interface LoginWebViewViewController () <UIWebViewDelegate>

@end

@implementation LoginWebViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Login", nil);
    
    [self.webView setDelegate:self];
    [self.activityView setHidesWhenStopped:YES];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    [self.activityView startAnimating];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.initialURL]];
    
    [self addOnePasswordButton:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonTapped:(id)sender {
    if (self.viewControllerDelegate && [self.viewControllerDelegate respondsToSelector:@selector(viewController:didTapDismissButton:)]) {
        [self.viewControllerDelegate viewController:self didTapDismissButton:sender];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIWebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *callbackURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
    if ([request.URL.scheme isEqualToString:callbackURL]) {
        return YES;
    }
    
    if ([request.URL.absoluteString rangeOfString:@"oauth/authorize"].location == NSNotFound) {
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityView stopAnimating];
    
    BOOL onePasswordAvailable = [[OnePasswordExtension sharedExtension] isAppExtensionAvailable];
    if (onePasswordAvailable) {
        [self addOnePasswordButton:YES];
    }
}

- (void)addOnePasswordButton:(BOOL)add {
    UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Skip", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didTapSkipButton:)];
    if (!add) {
        [self.navigationItem setRightBarButtonItems:@[skipButton]];
    } else {
        UIBarButtonItem *onePasswordButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"onepassword-navbar"] style:UIBarButtonItemStylePlain target:self action:@selector(fillUsing1Password:)];
        [self.navigationItem setRightBarButtonItems:@[onePasswordButton, skipButton]];
    }
}

- (void)didTapSkipButton:(id)sender {
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"By skipping login, you will not see private photos and you will not be able to upload to %@", nil), self.initialURL.host];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Guest Login", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", self.initialURL.host]];
        [[ConnectionManager sharedManager] connectAsGuest:url];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:continueAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - OnePassword

- (IBAction)fillUsing1Password:(id)sender {
    [[OnePasswordExtension sharedExtension] fillLoginIntoWebView:self.webView forViewController:self sender:sender completion:^(BOOL success, NSError *error) {
        if (!success) {
            
        }
    }];
}

@end
