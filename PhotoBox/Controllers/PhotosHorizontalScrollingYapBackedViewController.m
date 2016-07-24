//
//  PhotosHorizontalScrollingYapBackedViewController.m
//  Delightful
//
//  Created by  on 10/2/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "PhotosHorizontalScrollingYapBackedViewController.h"

#import "FlattenedPhotosDataSource.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import "PhotoZoomableCell.h"

@interface PhotosHorizontalScrollingYapBackedViewController () <PhotoZoomableCellDelegate, YapDataSourceDelegate>

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *groupedViewMapping;

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *viewMapping;

@end

@implementation PhotosHorizontalScrollingYapBackedViewController

+ (PhotosHorizontalScrollingYapBackedViewController *)defaultControllerWithGroupedViewMapping:(DLFYapDatabaseViewAndMapping *)groupedViewMapping {
    PhotosHorizontalLayout *layout = [[PhotosHorizontalLayout alloc] init];
    PhotosHorizontalScrollingYapBackedViewController *vc = [[PhotosHorizontalScrollingYapBackedViewController alloc] initWithCollectionViewLayout:layout groupedViewMapping:groupedViewMapping];
    return vc;
}

+ (PhotosHorizontalScrollingYapBackedViewController *)defaultControllerWithViewMapping:(DLFYapDatabaseViewAndMapping *)viewMapping {
    PhotosHorizontalLayout *layout = [[PhotosHorizontalLayout alloc] init];
    PhotosHorizontalScrollingYapBackedViewController *vc = [[PhotosHorizontalScrollingYapBackedViewController alloc] initWithCollectionViewLayout:layout viewMapping:viewMapping];
    return vc;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout groupedViewMapping:(DLFYapDatabaseViewAndMapping *)groupedViewMapping {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.groupedViewMapping = groupedViewMapping;
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout viewMapping:(DLFYapDatabaseViewAndMapping *)viewMapping {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.viewMapping = viewMapping;
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
    FlattenedPhotosDataSource *dataSource;
    if (self.viewMapping) {
        dataSource = [[FlattenedPhotosDataSource alloc] initWithCollectionView:self.collectionView viewMapping:self.viewMapping];
    } else {
        dataSource = [[FlattenedPhotosDataSource alloc] initWithCollectionView:self.collectionView groupedViewMapping:self.groupedViewMapping];
    }
    [dataSource setPause:YES];
    [dataSource setCellIdentifier:[self cellIdentifier]];
    __weak typeof (self) selfie = self;
    [dataSource setConfigureCellBlock:^(PhotoZoomableCell *cell, id item){
        [cell setItem:item];
        [cell setDelegate:selfie];
    }];
    [dataSource setDelegate:self];
    self.dataSource = dataSource;
}

#pragma mark - YapDataSourceDelegate

- (void)dataSourceDidModified:(YapDataSource *)dataSource {
    NSInteger numberOfItem = [dataSource numberOfItems];
    if (numberOfItem == 0) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
