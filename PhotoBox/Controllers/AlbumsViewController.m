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

@interface AlbumsViewController () <UIActionSheetDelegate>

@end

@implementation AlbumsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self setAlbumsCount:0 max:0];
    
    [super viewDidLoad];
    
    [self.collectionView setClipsToBounds:NO];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    [self.collectionView registerClass:[AlbumRowCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    [self.collectionView registerClass:[AlbumSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:self.sectionHeaderIdentifier];
    
    [self restoreContentInset];
    
    [self.collectionView setBackgroundColor:[UIColor albumsBackgroundColor]];
    
    
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

- (NSString *)sectionHeaderIdentifier {
    return @"albumSection";
}

- (NSString *)cellIdentifier {
    return @"albumCell";
}

- (CollectionViewHeaderCellConfigureBlock)headerCellConfigureBlock {
    void (^configureCell)(AlbumSectionHeaderView*, id,NSIndexPath*) = ^(AlbumSectionHeaderView* cell, id item,NSIndexPath *indexPath) {
        [cell setBackgroundColor:nil];
        [(UIView *)cell.blurView removeFromSuperview];
        [cell setText:NSLocalizedString(@"Gallery", nil)];
        [cell setHideLocation:YES];
        int count = cell.gestureRecognizers.count;
        if (count == 0) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnAllAlbum:)];
            [tap setNumberOfTapsRequired:1];
            [tap setNumberOfTouchesRequired:1];
            [cell addGestureRecognizer:tap];
        }
    };
    return configureCell;
}

- (NSString *)fetchedInIdentifier {
    return nil;
}

- (void)refreshIfNeeded {
    if ([[self resourceClass] needRefreshModelsCollection]) {
        [self refresh];
    } else {
        [self showLoadingView:YES atBottomOfScrollView:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *items = [[self resourceClass] modelsCollection];
            [self showLoadingView:NO atBottomOfScrollView:YES];
            if (items) {
                [self willLoadDataFromCache];
                
                [self.dataSource removeAllItems];
                [self.dataSource addItems:items];
                [self.collectionView reloadData];
                
                [self didLoadDataFromCache];
            } else {
                [self refresh];
            }
        });
    }
}

- (void)didLoadDataFromCache {
    NSInteger count = [self.dataSource numberOfItems];
    NSInteger totalPhotos = [[self resourceClass] totalCountCollection];
    [self setAlbumsCount:count max:totalPhotos];
    
    if (self.pageSize > 0) {
        self.page = ceil((double)count/(double)self.pageSize);
        self.totalPages = ceil((double)totalPhotos/(double)self.pageSize);
    } else {
        self.page = 1;
        self.totalPages = 1;
    }
    self.totalItems = totalPhotos;
    
    [self.collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top)];
}

- (void)processPaginationFromObjects:(id)objects {
    [super processPaginationFromObjects:objects];
    
    [[self resourceClass] setTotalCountCollection:self.totalItems];
}

#pragma mark - Scroll View

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    if (self.scrollDelegate && [self.scrollDelegate respondsToSelector:@selector(didScroll:)]) {
        [self.scrollDelegate didScroll:scrollView];
    }
}

- (void)scrollToTheTop {
    if (self.dataSource.items.count > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        [self scrollViewDidScroll:self.collectionView];
    }
}

#pragma mark - Did stuff

- (void)didFetchItems {
    NSInteger count = [self.dataSource numberOfItems];
    [self setAlbumsCount:count max:self.totalItems];
    
    [[self resourceClass] setModelsCollection:[self.dataSource flattenedItems]];
    [[self resourceClass] setModelsCollectionLastRefresh:[NSDate date]];
}

- (void)restoreContentInset {
    PBX_LOG(@"");
    [self.collectionView setContentInset:UIEdgeInsetsMake(self.headerViewHeight, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0)];
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
