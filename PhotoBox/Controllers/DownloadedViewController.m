//
//  DownloadedViewController.m
//  Delightful
//
//  Created by  on 11/16/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "DownloadedViewController.h"

#import "GroupedPhotosDataSource.h"

#import "DownloadedImageManager.h"

#import "DLFYapDatabaseViewAndMapping.h"

@interface DownloadedDataSource : GroupedPhotosDataSource

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *downloadedMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *flattenedDownloadedMapping;

@end

@interface DownloadedViewController ()

@end

@implementation DownloadedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [((YapDataSource *)self.dataSource) setPause:NO];
    [self restoreContentInset];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self restoreContentInset];
}

- (void)viewWillDisappear:(BOOL)animated {
    [((YapDataSource *)self.dataSource) setPause:YES];
}

- (void)pauseSync:(BOOL)pauseSync {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class)dataSourceClass {
    return [DownloadedDataSource class];
}

- (void)showEmptyLoading:(BOOL)show {
    [self showNoItems:show];
}

- (NSString *)noPhotosMessage {
    return NSLocalizedString(@"Downloaded photos will appear here", nil);
}

- (void)setupRefreshControl {
}

@end

@implementation DownloadedDataSource

- (void)setupMapping {
    self.downloadedMapping = [[DownloadedImageManager sharedManager] databaseViewMapping];
    self.flattenedDownloadedMapping = [[DownloadedImageManager sharedManager] flattenedDatabaseViewMapping];
}

- (void)setDefaultMapping {
    self.selectedViewMapping = self.downloadedMapping;
}

- (DLFYapDatabaseViewAndMapping *)selectedFlattenedViewMapping {
    return self.flattenedDownloadedMapping;
}

@end
