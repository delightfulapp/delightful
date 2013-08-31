//
//  PhotosViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosViewController.h"

#import "Album.h"
#import "Photo.h"

#import "PhotosViewControllerDataSource.h"

#import "PhotosSectionHeaderView.h"
#import "PhotoBoxCell.h"

#import "PhotosHorizontalScrollingViewController.h"

@interface PhotosViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation PhotosViewController

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
    [super viewDidLoad];
    
    [self setPhotosCount:0 max:0];
    
}

- (void)setupDataSource {
    PhotosViewControllerDataSource *dataSource = [[PhotosViewControllerDataSource alloc] init];
    [dataSource setGroupKey:[self groupKey]];
    [dataSource setSectionHeaderIdentifier:[self sectionHeaderIdentifier]];
    [dataSource setConfigureCellHeaderBlock:[self headerCellConfigureBlock]];
    self.dataSource = dataSource;
    [self.dataSource setCellIdentifier:[self cellIdentifier]];
    [self.collectionView setDataSource:self.dataSource];
    
    [self setupDataSourceConfigureBlock];
}

- (CollectionViewCellConfigureBlock)headerCellConfigureBlock {
    void (^configureCell)(PhotosSectionHeaderView*, id) = ^(PhotosSectionHeaderView* cell, id item) {
        [cell.titleLabel setText:[item objectForKey:[self groupKey]]];
    };
    return configureCell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)cellIdentifier {
    return @"photoCell";
}

- (NSString *)groupKey {
    return @"dateTakenString";
}

- (NSString *)sectionHeaderIdentifier {
    return @"photoSection";
}

- (ResourceType)resourceType {
    return PhotoResource;
}

- (NSString *)resourceId {
    return self.item.itemId;
}

- (void)didFetchItems {
    int count = self.items.count;
    [self setPhotosCount:count max:self.totalItems];
}


- (void)setPhotosCount:(int)count max:(int)max{
    NSString *title = NSLocalizedString(@"Photos", nil);
    Album *album = (Album *)self.item;
    if (album) {
        title = album.name;
    }
    if (count == 0) {
        self.title = title;
    } else {
        self.title = [NSString stringWithFormat:@"%@ (%d/%d)", title, count, max];
    }
}

#pragma mark - Header Things

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), 44);
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushPhoto"]) {
        PhotosHorizontalScrollingViewController *destination = (PhotosHorizontalScrollingViewController *)segue.destinationViewController;
        PhotoBoxCell *cell = (PhotoBoxCell *)sender;
        [destination setItem:self.item];
        [destination setItems:self.items];
        [destination setFirstShownPhoto:cell.item];
    }
}

@end
