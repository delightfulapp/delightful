//
//  OriginalImageDownloaderViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "OriginalImageDownloaderViewController.h"

#import "NPRImageDownloaderTableViewDataSource.h"

#import "DownloadCell.h"

static NSString *const downloadCellIdentifier = @"downloadCellIdentifier";

@interface OriginalImageDownloaderViewController ()

@property (nonatomic, strong) NPRImageDownloaderTableViewDataSource *dataSource;

@end

@implementation OriginalImageDownloaderViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[DownloadCell class] forCellReuseIdentifier:downloadCellIdentifier];
    
    self.dataSource = [[NPRImageDownloaderTableViewDataSource alloc] initWithTableView:self.tableView];
    [self.dataSource setCellIdentifier:downloadCellIdentifier];
    
    [self.dataSource setCellConfigureBlock:^(DownloadCell *cell, NPRImageDownloaderOperation *operation) {
        [cell.downloadThumbnailImageView setImage:operation.thumbnail];
        cell.downloadNameLabel.text = operation.name;
    }];
    
    self.title = NSLocalizedString(@"Downloads", nil);

    [self.tableView setRowHeight:50];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    [self.navigationItem setRightBarButtonItem:done];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
