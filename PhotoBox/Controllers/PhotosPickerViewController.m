//
//  PhotosPickerViewController.m
//  Delightful
//
//  Created by Nico Prananta on 6/2/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosPickerViewController.h"

#import "PhotosPickerGroupViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotosPickerViewController ()

@end

@implementation PhotosPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class)groupViewControllerClass {
    return [PhotosPickerGroupViewController class];
}


@end
