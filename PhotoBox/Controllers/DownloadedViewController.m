//
//  DownloadedViewController.m
//  Delightful
//
//  Created by  on 11/16/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DownloadedViewController.h"

#import "GroupedPhotosDataSource.h"

#import "DownloadedImageManager.h"

#import "DLFYapDatabaseViewAndMapping.h"

@interface DownloadedDataSource : GroupedPhotosDataSource

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *downloadedMapping;

@end

@interface DownloadedViewController ()

@end

@implementation DownloadedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class)dataSourceClass {
    return [DownloadedDataSource class];
}

- (NSString *)noPhotosMessage {
    return NSLocalizedString(@"Downloaded photos will appear here", nil);
}

@end

@implementation DownloadedDataSource

- (void)setupMapping {
    self.downloadedMapping = [[DownloadedImageManager sharedManager] databaseViewMapping];
}

- (void)setDefaultMapping {
    self.selectedViewMapping = self.downloadedMapping;
}

- (DLFYapDatabaseViewAndMapping *)selectedFlattenedViewMapping {
    return self.selectedViewMapping;
}

@end