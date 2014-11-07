//
//  LoginWebViewViewController.m
//  Delightful
//
//  Created by Nico Prananta on 5/22/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "LoginWebViewViewController.h"

#import <OnePasswordExtension.h>

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
        UIBarButtonItem *onePasswordButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"onepassword-navbar"] style:UIBarButtonItemStylePlain target:self action:@selector(fillUsing1Password:)];
        [self.navigationItem setRightBarButtonItem:onePasswordButton];
    }
}

#pragma mark - OnePassword

- (IBAction)fillUsing1Password:(id)sender {
    [[OnePasswordExtension sharedExtension] fillLoginIntoWebView:self.webView forViewController:self sender:sender completion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to fill login in webview: <%@>", error);
        }
    }];
}

@end
