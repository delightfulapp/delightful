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
#import "NSAttributedString+DelighftulFonts.h"
#import "AlbumsDataSource.h"
#import "SyncEngine.h"
#import "SortTableViewController.h"

@interface AlbumsViewController () <UIActionSheetDelegate, SortingDelegate, UICollectionViewDelegate>

@property (nonatomic, strong) NSString *currentSort;

@end

@implementation AlbumsViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    UIButton *sortingButton = [[UIButton alloc] init];
    NSMutableAttributedString *sortingSymbol = [[NSAttributedString symbol:dlf_icon_menu_sort size:25] mutableCopy];
    [sortingButton setAttributedTitle:sortingSymbol forState:UIControlStateNormal];
    [sortingButton sizeToFit];
    [sortingButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
    [sortingButton addTarget:self action:@selector(didTapSortButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:sortingButton];
    [self.navigationItem setRightBarButtonItem:leftItem];
    
    self.currentSort = @"dateLastPhotoAdded,desc";
        
    [self.collectionView registerClass:[AlbumRowCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    [self.collectionView setDelegate:self];
    
    self.title = NSLocalizedString(@"Albums", nil);
    
    [[SyncEngine sharedEngine] startSyncingAlbums];
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
