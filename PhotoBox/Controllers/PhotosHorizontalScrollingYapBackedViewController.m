//
//  PhotosHorizontalScrollingYapBackedViewController.m
//  Delightful
//
//  Created by  on 10/2/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosHorizontalScrollingYapBackedViewController.h"

#import "FlattenedPhotosDataSource.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import "PhotoZoomableCell.h"

@interface PhotosHorizontalScrollingYapBackedViewController ()

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *groupedViewMapping;

@end

@implementation PhotosHorizontalScrollingYapBackedViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout groupedViewMapping:(DLFYapDatabaseViewAndMapping *)groupedViewMapping {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.groupedViewMapping = groupedViewMapping;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDataSource {
    FlattenedPhotosDataSource *dataSource = [[FlattenedPhotosDataSource alloc] initWithCollectionView:self.collectionView groupedViewMapping:self.groupedViewMapping];
    [dataSource setCellIdentifier:[self cellIdentifier]];
    [dataSource setConfigureCellBlock:^(PhotoZoomableCell *cell, id item){
        [cell setItem:item];
    }];
    self.dataSource = dataSource;
}

@end
