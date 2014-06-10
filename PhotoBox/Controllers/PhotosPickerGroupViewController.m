//
//  PhotosPickerGroupViewController.m
//  Delightful
//
//  Created by Nico Prananta on 6/10/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosPickerGroupViewController.h"

#import "PhotosPickerAssetsViewController.h"

@interface PhotosPickerGroupViewController ()

@end

@implementation PhotosPickerGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class)assetsViewControllerClass {
    return [PhotosPickerAssetsViewController class];
}

@end
