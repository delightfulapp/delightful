//
//  AppDelegate.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AppDelegate.h"

#import "PhotoBoxNavigationControllerDelegate.h"

#import "ConnectionManager.h"

#import "NPRImageDownloader.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (isRunningTests()) {
        // if unit test, need to return quickly. Reference: http://www.objc.io/issue-1/testing-view-controllers.html
        return YES;
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *rootNavigationController = [storyBoard instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:rootNavigationController];
    [self.window setTintColor:[UIColor redColor]];
    [self.window makeKeyAndVisible];
    
    self.navigationDelegate = [[PhotoBoxNavigationControllerDelegate alloc] init];
    [rootNavigationController setDelegate:self.navigationDelegate];
    
    [self runCrashlytics];

    [[NPRImageDownloader sharedDownloader] addObserver:self forKeyPath:@"numberOfDownloads" options:0 context:NULL];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    NSString *urlScheme = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
    if ([[url scheme] isEqualToString:urlScheme]){
        NSArray *comp1 = [[url absoluteString] componentsSeparatedByString:@"?"];
        NSString *query = [comp1 lastObject];
        [[ConnectionManager sharedManager] continueOauthAuthorizationWithQuery:query];
    }
    
    return YES;
}


#pragma mark - Unit Test

static BOOL isRunningTests(void)
{
    
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}

#pragma mark - Crashlytics

- (void)runCrashlytics {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Crashlytics" ofType:@"plist"];
    if (filePath) {
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        if (dict) {
            NSString *apiKey = [dict objectForKey:@"key"];
            if (apiKey && apiKey.length > 0) {
                [Crashlytics startWithAPIKey:apiKey];
            }
        }
    }
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(numberOfDownloads))]) {
        if ([[NPRImageDownloader sharedDownloader] numberOfDownloads] > 0) {
            NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Downloading %1$d photo(s)", nil), [[NPRImageDownloader sharedDownloader] numberOfDownloads]];
            NSString *tapToSee = @"Tap to see progress";
            text = [text stringByAppendingString:[NSString stringWithFormat:@"\n%@", tapToSee]];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:[text rangeOfString:tapToSee]];
            [[NPRNotificationManager sharedManager] postNotificationWithImage:nil position:NPRNotificationPositionBottom type:NPRNotificationTypeNone string:attributedString accessoryType:NPRNotificationAccessoryTypeActivityView accessoryView:nil duration:0 onTap:^{
                [[NPRImageDownloader sharedDownloader] showDownloads];
            }];
        } else {
            [[NPRNotificationManager sharedManager] postNotificationWithImage:nil position:NPRNotificationPositionBottom type:NPRNotificationTypeSuccess string:NSLocalizedString(@"Image(s) are saved to Photo gallery", nil) accessoryType:NPRNotificationAccessoryTypeNone accessoryView:nil duration:3 onTap:nil];
        }
    }
}


@end
