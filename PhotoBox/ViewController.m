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
#import "Photo.h"
#import "Tag.h"
#import "ConnectionManager.h"

#import <AFNetworking.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[ConnectionManager sharedManager] setBaseURL:[NSURL URLWithString:@"http://nicnocquee.trovebox.com"]
                                      consumerKey:@"1aea715c0f861ee8c4421b6904396d"
                                   consumerSecret:@"8043463882"
                                       oauthToken:@"c2a234a82d5caf468bcc5ed84fc8b8"
                                      oauthSecret:@"a5669d36c8"];
//    [[PhotoBoxClient sharedClient] getPhotosInAlbum:@"7" page:1 success:^(id object) {
//        for (Photo *photo in object) {
//            NSLog(@"Photo %@: %@", photo.photoId, photo.thumbnailStringURL);
//        }
//    } failure:^(NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
////
//    [[PhotoBoxClient sharedClient] getTagsWithSuccess:^(id object) {
//        for (Tag *tag in object) {
//            NSLog(@"Tags: %@ (%d)", tag.tagId, tag.count);
//        }
//    } failure:^(NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
    [[PhotoBoxClient sharedClient] getAlbumsForPage:1 success:^(id object) {
        int i=0;
        for (Album *album in object) {
            if (i==0) {
                NSLog(@"Total row = %d\nTotal page = %d\nCurrent row %d\nCurrent Page = %d\n\n", album.totalRows, album.totalPages, album.currentRow, album.currentPage);
                i++;
            }
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
