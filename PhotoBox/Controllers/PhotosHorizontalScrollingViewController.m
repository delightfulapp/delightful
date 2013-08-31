//
//  PhotosHorizontalScrollingViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosHorizontalScrollingViewController.h"

#import "PhotoBoxModel.h"

@interface PhotosHorizontalScrollingViewController ()

@end

@implementation PhotosHorizontalScrollingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.collectionView setAlwaysBounceVertical:NO];
    [self.collectionView setAlwaysBounceHorizontal:YES];
    [self.collectionView setPagingEnabled:YES];
    
    [self.dataSource setCellIdentifier:[self cellIdentifier]];
    
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"Items = %d", self.items.count);
    
    [self scrollToFirstShownPhoto];
}

- (void)scrollToFirstShownPhoto {
    NSAssert(self.items!=nil, @"Items should not be nil here");
    int index = [self.items indexOfObject:self.firstShownPhoto];
    if (index != NSNotFound) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override setup

- (NSString *)cellIdentifier {
    return @"photoZoomableCell";
}

- (void)setupPinchGesture {
    // pinch not needed
}

- (void)setupRefreshControl {
    // refresh control not needed
}

- (ResourceType)resourceType {
    return PhotoResource;
}

- (NSString *)resourceId {
    return self.item.itemId;
}


#pragma mark - Scroll View

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}


#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.frame.size.width;
    CGFloat height = collectionView.frame.size.height - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom;
    return CGSizeMake(width, height);
}

@end
