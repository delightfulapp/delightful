//
//  ViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "ViewController.h"

#import "PhotoBoxClient.h"
#import "Album.h"
#import "ConnectionManager.h"

#import <AFNetworking.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    AFOAuth1Client *client = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:@"http://nicnocquee.trovebox.com"] key:@"1aea715c0f861ee8c4421b6904396d" secret:@"8043463882"];
//    AFOAuth1Token *accessToken = [[AFOAuth1Token alloc] initWithKey:@"c2a234a82d5caf468bcc5ed84fc8b8" secret:@"a5669d36c8" session:nil expiration:nil renewable:YES];
//    BOOL success = [AFOAuth1Token storeCredential:accessToken withIdentifier:@"trovebox"];
//    //NSAssert(success, @"Fail storing credential");
//    [client setAccessToken:accessToken];
//    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
//    [client getPath:@"/albums/list.json?page=2" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
    [[ConnectionManager sharedManager] setBaseURL:[NSURL URLWithString:@"http://nicnocquee.trovebox.com"]
                                      consumerKey:@"1aea715c0f861ee8c4421b6904396d"
                                   consumerSecret:@"8043463882"
                                       oauthToken:@"c2a234a82d5caf468bcc5ed84fc8b8"
                                      oauthSecret:@"a5669d36c8"];
    
    [[PhotoBoxClient sharedClient] getAlbumsForPage:1 success:^(id object) {
        for (Album *album in object) {
            NSLog(@"\nName: %@\nImage: %@\n\n", album.name, [album albumCover:path200x200xCR]);
        }
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
