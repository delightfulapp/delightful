//
//  UploadViewController.m
//  Delightful
//
//  Created by Nico Prananta on 6/21/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "UploadViewController.h"

#import "UploadAssetCell.h"

#import "UploadHeaderView.h"

#import <UIView+AutoLayout.h>

#import "DLFImageUploader.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "DelightfulCache.h"


@interface UploadViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UploadHeaderView *headerView;

@property (nonatomic, strong) NSMutableArray *internalUploads;

@end

@implementation UploadViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerView = [[UploadHeaderView alloc] initWithFrame:CGRectZero];
    [self.headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.headerView];
    [self.headerView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [self.headerView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    [self.headerView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
    [self.headerView autoSetDimension:ALDimensionHeight toSize:UPLOAD_BAR_HEIGHT];
    
    [self.collectionView registerClass:[UploadAssetCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    
    [self.collectionView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [self.collectionView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    [self.collectionView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.headerView];
    [self.collectionView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    
    [self.headerView setNumberOfUploads:self.uploads.count];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgressNotification:) name:DLFAssetUploadProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDoneNotification:) name:DLFAssetUploadDidSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadNumberChangeNotification:) name:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil];
}

- (void)startUpload {
    for (ALAsset *asset in self.uploads) {
        [[DLFImageUploader sharedUploader] queueAsset:asset];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUploads:(NSArray *)uploads {
    if (_uploads != uploads) {
        _uploads = uploads;
        
        _internalUploads = [_uploads mutableCopy];
    }
}

#pragma mark - Getters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setItemSize:CGSizeMake(UPLOAD_ITEM_WIDTH, UPLOAD_ITEM_WIDTH)];
        [layout setMinimumInteritemSpacing:1];
        [layout setMinimumLineSpacing:1];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_collectionView setAlwaysBounceVertical:NO];
        [_collectionView setAlwaysBounceHorizontal:YES];
        [_collectionView setBackgroundColor:[UIColor tabBarTintColor]];
        
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (NSString *)cellIdentifier {
    return @"uploadPhotoCell";
}

- (NSString *)headerIdentifier {
    return @"uploadHeaderIdentifier";
}

#pragma mark - Collection View Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UploadAssetCell *cell = (UploadAssetCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[self cellIdentifier] forIndexPath:indexPath];
    [cell setItem:[self.internalUploads objectAtIndex:indexPath.item]];
    return cell;
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.internalUploads.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - Upload observers

- (void)uploadNumberChangeNotification:(NSNotification *)notification {
    NSInteger numberOfUploads = [notification.userInfo[kNumberOfUploadsKey] integerValue];
    [self.headerView setNumberOfUploads:numberOfUploads];
}

- (void)uploadProgressNotification:(NSNotification *)notification {
    NSURL *assetURL = notification.userInfo[kAssetURLKey];
    
    for (UploadAssetCell *cell in self.collectionView.visibleCells) {
        ALAsset *cellAsset = (ALAsset *)cell.item;
        if ([[cellAsset valueForProperty:ALAssetPropertyAssetURL] isEqual:assetURL]) {
            [cell setUploadProgress:[notification.userInfo[kProgressKey] floatValue]];
            break;
        }
    }
}

- (void)uploadDoneNotification:(NSNotification *)notification {
    NSURL *assetURL = notification.userInfo[kAssetURLKey];
    [self logUploadedAssetURL:assetURL];
    
    if (self.internalUploads.count == 1) {
        return;
    }
    
    NSInteger index = [self.internalUploads indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(ALAsset *obj, NSUInteger idx, BOOL *stop) {
        if ([[obj valueForProperty:ALAssetPropertyAssetURL] isEqual:assetURL]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (index != NSNotFound) {
        [self.internalUploads removeObjectAtIndex:index];
        
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)logUploadedAsset:(ALAsset *)asset {
    NSURL *URL = [asset valueForProperty:ALAssetPropertyAssetURL];
    [self logUploadedAssetURL:URL];
}

- (void)logUploadedAssetURL:(NSURL *)URL {
    NSMutableOrderedSet *uploaded = [[[DelightfulCache sharedCache] objectForKey:DLF_UPLOADED_ASSETS] mutableCopy];
    if (!uploaded) {
        uploaded = [NSMutableOrderedSet orderedSet];
    }
    [uploaded addObject:URL];
    [[DelightfulCache sharedCache] setObject:uploaded forKey:DLF_UPLOADED_ASSETS];
}

@end
