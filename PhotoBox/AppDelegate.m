//
//  AppDelegate.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AppDelegate.h"

#import "ConnectionManager.h"

#import "NPRImageDownloader.h"

#import <MessageUI/MessageUI.h>

#import "UIWindow+Additionals.h"

#import "PhotosViewController.h"

#import "AlbumsViewController.h"

#import "TagsViewController.h"

#import "StickyHeaderFlowLayout.h"

#import "Album.h"

#import "DLFImageUploader.h"

#import "SyncEngine.h"

#import "SDWebImageManager.h"

// #import <COSTouchVisualizerWindow.h>

static void * imageDownloadContext = &imageDownloadContext;

static void * imageUploadContext = &imageUploadContext;

@interface AppDelegate () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (isRunningTests()) {
        // if unit test, need to return quickly. Reference: http://www.objc.io/issue-1/testing-view-controllers.html
        return YES;
    }
        
    [[[SDWebImageManager sharedManager] imageCache] setMaxCacheAge:DEFAULT_PHOTOS_CACHE_AGE];
    
    [self.window setTintColor:[UIColor redColor]];
    
    [self runCrashlytics];
    
    return YES;
}

/*
 // uncomment this to show touches when recording demo
- (COSTouchVisualizerWindow *)window
{
    static COSTouchVisualizerWindow *visWindow = nil;
    if (!visWindow) visWindow = [[COSTouchVisualizerWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    return visWindow;
}
 */
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSString *appVersion = [NSString stringWithFormat:@"%@ %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    PBX_LOG(@"App version: %@", appVersion);
    [[NSUserDefaults standardUserDefaults] setObject:appVersion forKey:APP_VERSION_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
#if __has_include("Crashlytics/Crashlytics.h")
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Crashlytics" ofType:@"plist"];
    if (filePath) {
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        if (dict) {
            NSString *apiKey = [dict objectForKey:@"key"];
            if ((apiKey && apiKey.length > 0)  && ![apiKey isEqualToString:@"<YOUR_KEY_HERE>"]) {
                PBX_LOG(@"Starting Crashlytics");
                if (![Crashlytics startWithAPIKey:apiKey]) {
                    PBX_LOG(@"No crashlytics");
                }
            }
        }
    }
#endif
}

- (void)showNotificationString:(id)attributedString type:(NPRNotificationType)type accessoryType:(NPRNotificationAccessoryType)accessoryType duration:(NSInteger)duration onTap:(void(^)())onTap {
    [[NPRNotificationManager sharedManager] postNotificationWithImage:nil position:NPRNotificationPositionBottom type:type string:attributedString accessoryType:accessoryType accessoryView:nil duration:duration onTap:onTap];
}

#pragma mark - Message, Mail

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [[UIWindow topMostViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[UIWindow topMostViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
