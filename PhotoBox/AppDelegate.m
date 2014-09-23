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

#import "IntroViewController.h"

#import <MessageUI/MessageUI.h>

#import "UIWindow+Additionals.h"

#import "PhotosViewController.h"

#import "AlbumsViewController.h"

#import "TagsViewController.h"

#import "AlbumsTagsViewController.h"

#import "StickyHeaderFlowLayout.h"

#import "PanelsContainerViewController.h"

#import "Album.h"

#import <JASidePanelController.h>

#import "LeftViewController.h"

#import "DLFImageUploader.h"

#import <Lookback/Lookback.h>

//#import "HintsViewController.h"

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
    
    //[[ConnectionManager sharedManager] logout];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:PBX_SHOWN_INTRO_VIEW_USER_DEFAULT_KEY];
    //[[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.delightful.kDownloadedImageManagerKey"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.delightful.kFavoritesManagerKey"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    NSString *previousAppVersion = [[NSUserDefaults standardUserDefaults] objectForKey:APP_VERSION_KEY];
//    if (previousAppVersion) {
//        previousAppVersion = [[previousAppVersion componentsSeparatedByString:@" "] firstObject];
//        if ([previousAppVersion isEqualToString:@"1.0.0"]) {
//            [[ConnectionManager sharedManager] logoutWithShowingLoginScreen:NO];
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update v1.0.1" message:NSLocalizedString(@"There is caching improvement in this update but you need to be logged out of the app. Please login again. Sorry for the inconvenience.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil];
//            [alert show];
//        }
//    }
    
    PanelsContainerViewController *rootViewController = [[PanelsContainerViewController alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:rootViewController];
    [self.window setTintColor:[UIColor redColor]];
    [self.window makeKeyAndVisible];
    
    PhotosViewController *photosViewController = [[PhotosViewController alloc] initWithCollectionViewLayout:[[StickyHeaderFlowLayout alloc] init]];
    UINavigationController *photosNavigationViewController = [[UINavigationController alloc] initWithRootViewController:photosViewController];
    [photosViewController setItem:[Album allPhotosAlbum]];
    
    /*
    AlbumsViewController *albumsViewController = [[AlbumsViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    TagsViewController *tagsViewController = [[TagsViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    AlbumsTagsViewController *albumsTagsViewController = [[AlbumsTagsViewController alloc] init];
    [albumsTagsViewController setViewControllers:@[albumsViewController, tagsViewController]];
    LeftViewController *left = [[LeftViewController alloc] initWithRootViewController:albumsTagsViewController];
    [rootViewController setLeftPanel:left];
     */
    [rootViewController setCenterPanel:photosNavigationViewController];
    
    self.navigationDelegate = [[PhotoBoxNavigationControllerDelegate alloc] init];
    [photosNavigationViewController setDelegate:self.navigationDelegate];
    
    [self runCrashlytics];
    
    [self runLookback];

    [[NPRImageDownloader sharedDownloader] addObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfDownloads)) options:0 context:imageDownloadContext];
    
    //[[DLFImageUploader sharedUploader] addObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfUploading)) options:0 context:imageUploadContext];
    
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

#pragma mark - Navigation

- (void)showAllPhotosWithStoryboard:(UIStoryboard *)storyBoard rootViewController:(UINavigationController *)rootNavigationController {
    PhotosViewController *photos = [storyBoard instantiateViewControllerWithIdentifier:@"photosViewController"];
    [photos setItem:[Album allPhotosAlbum]];
    [rootNavigationController pushViewController:photos animated:NO];
}

#pragma mark - Orientation
//
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//    NSUInteger orientations = UIInterfaceOrientationMaskAllButUpsideDown;
//    
//    if(self.window.rootViewController){
//        UIViewController *presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
//        orientations = [presentedViewController supportedInterfaceOrientations];
//    }
//    
//    return orientations;
//}


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

- (void)runLookback {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Lookback" ofType:@"plist"];
    if (filePath) {
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        if (dict) {
            NSString *apiKey = [dict objectForKey:@"token"];
            if ((apiKey && apiKey.length > 0) && ![apiKey isEqualToString:@"<YOUR_TOKEN_HERE>"]) {
                [Lookback_Weak setupWithAppToken:apiKey];
                [Lookback_Weak lookback].shakeToRecord = YES;
            }
        }
    }
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(numberOfDownloads))] && context == imageDownloadContext) {
        if ([[NPRImageDownloader sharedDownloader] numberOfDownloads] > 0) {
            NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Downloading %1$d photo(s)", nil), [[NPRImageDownloader sharedDownloader] numberOfDownloads]];
            NSString *tapToSee = @"Tap to see progress";
            text = [text stringByAppendingString:[NSString stringWithFormat:@"\n%@", tapToSee]];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:[text rangeOfString:tapToSee]];
            [self showNotificationString:attributedString type:NPRNotificationTypeNone accessoryType:NPRNotificationAccessoryTypeActivityView duration:0 onTap:^{
                [[NPRImageDownloader sharedDownloader] showDownloads];
            }];
        } else {
            [self showNotificationString:NSLocalizedString(@"Image(s) are saved to Photo gallery", nil) type:NPRNotificationTypeSuccess accessoryType:NPRNotificationAccessoryTypeNone duration:3 onTap:nil];
        }
    } else if (context == imageUploadContext) {
        if ([[DLFImageUploader sharedUploader] numberOfUploading] > 0) {
            NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Uploading %1$d photo(s)", nil), [[DLFImageUploader sharedUploader] numberOfUploading]];
            NSString *tapToSee = @"Tap to see progress";
            text = [text stringByAppendingString:[NSString stringWithFormat:@"\n%@", tapToSee]];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:[text rangeOfString:tapToSee]];
            [self showNotificationString:attributedString type:NPRNotificationTypeNone accessoryType:NPRNotificationAccessoryTypeActivityView duration:0 onTap:^{
                [[NPRImageDownloader sharedDownloader] showDownloads];
            }];
        } else {
            [self showNotificationString:NSLocalizedString(@"Photos uploaded", nil) type:NPRNotificationTypeSuccess accessoryType:NPRNotificationAccessoryTypeNone duration:3 onTap:nil];
        }
    }
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

#pragma mark - Intro

- (BOOL)showUpdateInfoViewIfNeeded {
    if ([[ConnectionManager sharedManager] isUserLoggedIn]) {
        NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        if (![currentVersion isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:PBX_SHOWN_INTRO_VIEW_USER_DEFAULT_KEY]]) {
            if ([self versionInfOPlistExistsForVersion:currentVersion]) {
                IntroViewController *intro = [[IntroViewController alloc] init];
                [[UIWindow topMostViewController] presentViewController:intro animated:YES completion:nil];
                [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:PBX_SHOWN_INTRO_VIEW_USER_DEFAULT_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)versionInfOPlistExistsForVersion:(NSString *)version {
    NSString * filePath = [[NSBundle bundleForClass:[self class]] pathForResource:version ofType:@"plist"];
    return (filePath)?YES:NO;
}

@end
