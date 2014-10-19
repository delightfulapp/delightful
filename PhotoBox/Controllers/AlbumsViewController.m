//
//  AlbumsViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumsViewController.h"

#import "PhotosCollection.h"
#import "Album.h"
#import "AlbumRowCell.h"
#import "PhotosViewController.h"
#import "DelightfulRowCell.h"
#import "ConnectionManager.h"
#import "AppDelegate.h"
#import "UIViewController+Additionals.h"
#import "AlbumsDataSource.h"
#import "SyncEngine.h"

@interface AlbumsViewController () <UIActionSheetDelegate>

@end

@implementation AlbumsViewController

- (void)viewDidLoad
{
    [self setAlbumsCount:0 max:0];
    
    [super viewDidLoad];
        
    [self.collectionView registerClass:[AlbumRowCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    
    self.title = NSLocalizedString(@"Albums", nil);
    
    [[SyncEngine sharedEngine] startSyncingAlbums];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.collectionView reloadData];
}

- (void)setAlbumsCount:(int)count max:(int)max{
    if (count == 0) {
        self.title = NSLocalizedString(@"Albums", nil);
    } else {
        self.title = [NSString stringWithFormat:@"%@ (%d/%d)", NSLocalizedString(@"Albums", nil), count, max];
    }
    
    [self.tabBarItem setTitle:self.title];
    [self.tabBarItem setImage:[[UIImage imageNamed:@"Albums"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)restoreContentInset {
    [self.collectionView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [self.collectionView setScrollIndicatorInsets:self.collectionView.contentInset];
}

#pragma mark - Getters

- (NSArray *)sortDescriptors {
    return nil;
}

- (ResourceType)resourceType {
    return AlbumResource;
}

- (Class)resourceClass {
    return [Album class];
}

- (NSString *)cellIdentifier {
    return @"albumCell";
}

- (Class)dataSourceClass {
    return AlbumsDataSource.class;
}

#pragma mark - Did stuff


- (void)setupPinchGesture {
    // override with empty implementation because we don't need the albums pinchable.
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Album *album = (Album *)[self.dataSource itemAtIndexPath:indexPath];
    AlbumRowCell *cell = (AlbumRowCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [album setAlbumThumbnailImage:cell.cellImageView.image];
}

#pragma mark - Collection View Flow Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.frame);
    return CGSizeMake(collectionViewWidth, 80);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

@end
