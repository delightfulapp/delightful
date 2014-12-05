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
#import "Photo.h"
#import "AlbumRowCell.h"
#import "PhotosViewController.h"
#import "DelightfulRowCell.h"
#import "ConnectionManager.h"
#import "AppDelegate.h"
#import "UIViewController+Additionals.h"
#import "AlbumsDataSource.h"
#import "SyncEngine.h"
#import "SortTableViewController.h"
#import "PhotosSubsetViewController.h"
#import "SortingConstants.h"

@interface AlbumsViewController () <UIActionSheetDelegate, SortingDelegate, UICollectionViewDelegate>

@property (nonatomic, strong) NSString *currentSort;

@end

@implementation AlbumsViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    self.currentSort = dateLastPhotoAddedDescSortKey;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:DLF_LAST_SELECTED_ALBUMS_SORT]) {
        self.currentSort = [[NSUserDefaults standardUserDefaults] objectForKey:DLF_LAST_SELECTED_ALBUMS_SORT];
    }
        
    [self.collectionView registerClass:[AlbumRowCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    [self.collectionView setDelegate:self];
    
    self.title = NSLocalizedString(@"Albums", nil);
    
    [[SyncEngine sharedEngine] startSyncingAlbums];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[SyncEngine sharedEngine] pauseSyncingAlbums:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[SyncEngine sharedEngine] pauseSyncingAlbums:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapSortButton:(NSNotification *)notification {
    SortTableViewController *sort = [[SortTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [sort setResourceClass:Album.class];
    [sort setSortingDelegate:self];
    [sort setSelectedSort:self.currentSort];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sort];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - SortingDelegate

- (void)sortTableViewController:(id)sortTableViewController didSelectSort:(NSString *)sort {
    if (![self.currentSort isEqualToString:sort]) {
        self.currentSort = sort;
        [[NSUserDefaults standardUserDefaults] setObject:self.currentSort forKey:DLF_LAST_SELECTED_ALBUMS_SORT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        AlbumsSortKey selectedSortKey;
        NSArray *sortArray = [sort componentsSeparatedByString:@","];
        if ([[sortArray objectAtIndex:0] isEqualToString:NSStringFromSelector(@selector(dateLastPhotoAdded))]) {
            selectedSortKey = AlbumsSortKeyDateLastUpdated;
        } else {
            selectedSortKey = AlbumsSortKeyName;
        }
        BOOL ascending = YES;
        if ([[[sortArray objectAtIndex:1] lowercaseString] isEqualToString:@"desc"]) {
            ascending = NO;
        }
        [((AlbumsDataSource *)self.dataSource) sortBy:selectedSortKey ascending:ascending];
        [[SyncEngine sharedEngine] refreshResource:NSStringFromClass([Album class])];
        [sortTableViewController dismissViewControllerAnimated:YES completion:^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }];
    } else {
        [sortTableViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Getters

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
    NSString *albumId = [album.albumId copy];
    
    PhotosSubsetViewController *subsetController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"photosSubsetViewController"];
    [subsetController setItem:album];
    [subsetController setObjectKey:NSStringFromSelector(@selector(albums))];
    [subsetController setFilterName:[NSString stringWithFormat:@"album-%@", albumId]];
    
    [self.navigationController pushViewController:subsetController animated:YES];
}

#pragma mark - Collection View Flow Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionViewWidth = CGRectGetWidth(self.view.frame);
    return CGSizeMake(collectionViewWidth, 80);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

@end
