//
//  SharerManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/24/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "SharerManager.h"

#import <Social/Social.h>

#import "UIWindow+Additionals.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MessageUI/MessageUI.h>

@implementation SharerManager

+ (void)shareTo:(ShareType)service URL:(NSURL *)URL text:(NSString *)text subject:(NSString *)subject {
    switch (service) {
        case ShareTypeTwitter:
            [[self class] shareToTwitterWithInitialText:text url:nil];
            break;
        case ShareTypeSMS:{
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
                [messageCompose setMessageComposeDelegate:[[UIApplication sharedApplication] delegate]];
                [messageCompose setBody:text];
                [[UIWindow topMostViewController]  presentViewController:messageCompose animated:YES completion:nil];
            }
            break;
        }
        case ShareTypeFacebook:
            [[self class] shareToFacebookWithInitialText:text url:URL];
            break;
            
        case ShareTypeEmail:{
            UIViewController *root = [UIWindow topMostViewController];
            MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
            [mailCompose setSubject:subject];
            [mailCompose setMessageBody:text isHTML:YES];
            [mailCompose setMailComposeDelegate:[[UIApplication sharedApplication] delegate]];
            [root  presentViewController:mailCompose animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

+ (void)shareToFacebookWithInitialText:(NSString *)text url:(NSURL *)url{
    UIViewController *root = [UIWindow topMostViewController];
    
    if (![FBDialogs presentOSIntegratedShareDialogModallyFrom:root initialText:text image:nil url:url handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {}]) {
        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         text, @"name",
         url.absoluteString, @"link",
         nil];
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 // Error launching the dialog or publishing a story.
                 NSLog(@"Error publishing story.");
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                     NSLog(@"User canceled story publishing.");
                 } else {
                     // Handle the publish feed callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"post_id"]) {
                         // User clicked the Cancel button
                         NSLog(@"User canceled story publishing.");
                     } else {
                         // User clicked the Share button
                         NSString *msg = [NSString stringWithFormat:
                                          @"Posted story, id: %@",
                                          [urlParams valueForKey:@"post_id"]];
                         NSLog(@"%@", msg);
                         // Show the result in an alert
                         
                     }
                 }
             }
         }];
    }
}

+ (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

+ (void)shareToTwitterWithInitialText:(NSString *)text url:(NSString *)url{
    UIViewController *root = [UIWindow topMostViewController];
    SLComposeViewController *tw = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tw setInitialText:text];
    if (url) [tw addURL:[NSURL URLWithString:url]];
    SLComposeViewControllerCompletionHandler completionHandler =
    ^(SLComposeViewControllerResult result) {
        switch (result)
        {
            case SLComposeViewControllerResultCancelled:
                
                break;
            case SLComposeViewControllerResultDone:
                break;
            default:
                break;
        }
        [root dismissViewControllerAnimated:YES completion:nil];
    };
    [tw setCompletionHandler:completionHandler];
    [root presentViewController:tw animated:YES completion:nil];
}

@end
