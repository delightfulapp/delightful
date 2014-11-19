//
//  NPRImageDownloaderTableViewDataSource.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "NPRImageDownloaderTableViewDataSource.h"
#import "NPRImageDownloader.h"

@interface NPRImageDownloaderTableViewDataSource ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation NPRImageDownloaderTableViewDataSource

- (id)initWithTableView:(UITableView *)tableView {
    if (self = [super init]) {
        _tableView = tableView;
        _tableView.dataSource = self;
        [[NPRImageDownloader sharedDownloader] setDelegate:self];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[NPRImageDownloader sharedDownloader] numberOfDownloads];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    if (self.cellConfigureBlock) {
        self.cellConfigureBlock(cell, [[NPRImageDownloader sharedDownloader] downloadOperationAtIndex:indexPath.row]);
    }
    return cell;
}

#pragma mark - NPRImageDownloaderDelegate

- (void)didFailDownloadOperation:(NPRImageDownloaderOperation *)operation atIndex:(NSInteger)index {
    PBX_LOG(@"Download %@ failed at index: %d", operation.URL, index);
}

- (void)didStartDownloadOperation:(id)operation {
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didFinishDownloadOperation:(id)operation atIndex:(NSInteger)index{
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didProgress:(float)progress forOperation:(id)operation atIndex:(NSInteger)index{
    UITableViewCell<NPRImageDownloaderProgressIndicator> *cell = (UITableViewCell<NPRImageDownloaderProgressIndicator> *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (cell) {
        [cell downloadProgressDidChange:progress];
    }
}

@end
