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

#import "PureLayout.h"

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
    
    [self showNoDownloads:YES];
    
    [self.tableView registerClass:[DownloadCell class] forCellReuseIdentifier:downloadCellIdentifier];
    
    self.dataSource = [[NPRImageDownloaderTableViewDataSource alloc] initWithTableView:self.tableView];
    [self.dataSource setCellIdentifier:downloadCellIdentifier];
    
    [self.dataSource setCellConfigureBlock:^(DownloadCell *cell, NPRImageDownloaderOperation *operation) {
        [cell.downloadThumbnailImageView setImage:operation.thumbnail];
        cell.downloadNameLabel.text = operation.name;
    }];
    
    self.title = NSLocalizedString(@"Downloads", nil);

    [self.tableView setRowHeight:50];
    
    [self.tableView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showNoDownloads:(BOOL)show {
    if (show) {
        UIView *whiteView = [[UIView alloc] initWithFrame:self.tableView.frame];
        [whiteView setBackgroundColor:[UIColor whiteColor]];
        UILabel *textLabel = [[UILabel alloc] initForAutoLayout];
        [textLabel setText:NSLocalizedString(@"You have no active downloads.", nil)];
        [textLabel setTextColor:[UIColor grayColor]];
        [textLabel sizeToFit];
        [whiteView addSubview:textLabel];
        [textLabel autoCenterInSuperview];
        [textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:whiteView withOffset:20 relation:NSLayoutRelationGreaterThanOrEqual];
        [textLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:whiteView withOffset:-20 relation:NSLayoutRelationLessThanOrEqual];
        [self.tableView setBackgroundView:whiteView];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    } else {
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [self.tableView setBackgroundView:nil];
    }
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        if ([self.tableView numberOfRowsInSection:0] == 0) {
            [self showNoDownloads:YES];
        } else {
            [self showNoDownloads:NO];
        }
    }
}

@end
