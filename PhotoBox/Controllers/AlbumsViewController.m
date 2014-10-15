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
#import "AlbumSectionHeaderView.h"
#import "DelightfulRowCell.h"

#import "ConnectionManager.h"

#import "UIViewController+DelightfulViewControllers.h"

#import <JASidePanelController.h>
#import "AppDelegate.h"

#import "UIViewController+Additionals.h"

#import "AlbumsDataSource.h"

#import <TMCache.h>

@interface AlbumsViewController () <UIActionSheetDelegate>

@end

@implementation AlbumsViewController

- (void)viewDidLoad
{
    [self setAlbumsCount:0 max:0];
    
    [super viewDidLoad];
        
    [self.collectionView registerClass:[AlbumRowCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    
    self.title = NSLocalizedString(@"Albums", nil);
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

- (void)processPaginationFromObjects:(id)objects {
    [super processPaginationFromObjects:objects];
    
    [[self resourceClass] setTotalCountCollection:self.totalItems];
}

- (Class)dataSourceClass {
    return AlbumsDataSource.class;
}

#pragma mark - Did stuff

- (void)didFetchItems {
    NSInteger count = [self.dataSource numberOfItems];
    [self setAlbumsCount:count max:self.totalItems];
}

- (void)setupPinchGesture {
    // override with empty implementation because we don't need the albums pinchable.
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Album *album = (Album *)[self.dataSource itemAtIndexPath:indexPath];
    AlbumRowCell *cell = (AlbumRowCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [album setAlbumThumbnailImage:cell.cellImageView.image];
    [self loadPhotosInAlbum:album];
}

#pragma mark - Tap

- (void)tapOnAllAlbum:(UITapGestureRecognizer *)gesture {
    [self loadPhotosInAlbum:[Album allPhotosAlbum]];
}

- (void)userTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to logout?", Nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Log out", nil), nil];
    [actionSheet showInView:self.navigationController.view];
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{
            [[ConnectionManager sharedManager] logout];
            break;
        }
        default:
            break;
    }
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
