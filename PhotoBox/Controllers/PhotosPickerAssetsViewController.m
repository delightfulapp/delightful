//
//  PhotosPickerAssetsViewController.m
//  Delightful
//
//  Created by Nico Prananta on 6/10/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosPickerAssetsViewController.h"

#import "DLFAssetsViewCell.h"

#import "DelightfulCache.h"

@interface PhotosPickerAssetsViewController ()

@property (nonatomic, copy) NSArray *uploadedAssets;

@end

@implementation PhotosPickerAssetsViewController

- (id)init {
    self = [super init];
    if (self) {
        [self.collectionView registerClass:[DLFAssetsViewCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.uploadedAssets = [[DelightfulCache sharedCache] objectForKey:DLF_UPLOADED_ASSETS];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Next", nil);
    
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)cellIdentifier {
    return @"DLFAssetsCellIdentifier";
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLFAssetsViewCell *cell = (DLFAssetsViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    NSURL *assetURL = [cell.asset valueForProperty:ALAssetPropertyAssetURL];
    [cell setUploaded:[self.uploadedAssets containsObject:assetURL]];
    
    return cell;
}

@end
