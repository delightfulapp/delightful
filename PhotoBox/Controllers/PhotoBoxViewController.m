//
//  PhotoBoxViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxViewController.h"

#import "ConnectionManager.h"

#import "PhotoBoxCell.h"
#import "PhotoBoxModel.h"

#import "UIViewController+Additionals.h"
#import "UIScrollView+Additionals.h"

@interface PhotoBoxViewController () <UICollectionViewDelegateFlowLayout> {
    CGFloat lastOffset;
}

@end

@implementation PhotoBoxViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    if (![[ConnectionManager sharedManager] baseURL]) {
        [[ConnectionManager sharedManager] setBaseURL:[NSURL URLWithString:@"http://nicnocquee.trovebox.com"]
                                          consumerKey:@"1aea715c0f861ee8c4421b6904396d"
                                       consumerSecret:@"8043463882"
                                           oauthToken:@"c2a234a82d5caf468bcc5ed84fc8b8"
                                          oauthSecret:@"a5669d36c8"];
    }
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setAlwaysBounceVertical:YES];
    [self.collectionView setAlwaysBounceVertical:YES];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.page = 1;
    self.numberOfColumns = 2;
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewPinched:)];
    [self.collectionView addGestureRecognizer:pinch];
    
    [self setupDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    int count = self.items.count;
    if (count == 0) {
        [self fetchResource];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDataSource {
    self.dataSource = [[CollectionViewDataSource alloc] init];
    self.collectionView.dataSource = self.dataSource;
    [self setupDataSourceConfigureBlock];
}

- (void)setupDataSourceConfigureBlock {
    [self.dataSource setConfigureCellBlock:[self cellConfigureBlock]];
}

- (CollectionViewCellConfigureBlock)cellConfigureBlock {
    void (^configureCell)(PhotoBoxCell*, id) = ^(PhotoBoxCell* cell, id item) {
        [cell setItem:item];
    };
    return configureCell;
}

- (void)fetchResource {
    [self showLoadingView:YES];

    [[PhotoBoxClient sharedClient] getResource:self.resourceType
                                        action:ListAction
                                    resourceId:self.resourceId
                                          page:self.page
                                       success:^(id objects) {
                                           [self showLoadingView:NO];
                                           if (objects) {
                                               PhotoBoxModel *firstObject = (PhotoBoxModel *)[objects objectAtIndex:0];
                                               self.totalItems = firstObject.totalRows;
                                               self.totalPages = firstObject.totalPages;
                                               self.currentPage = firstObject.currentPage;
                                               self.currentRow = firstObject.currentRow;
                                               
                                               [self.items addObjectsFromArray:objects];
                                               [self.dataSource setItems:self.items];
                                               [self.collectionView reloadData];
                                               self.isFetching = NO;
                                               [self didFetchItems];
                                               int count = self.items.count;
                                               if (count==self.totalItems) {
                                                   [self performSelector:@selector(restoreContentInset) withObject:Nil afterDelay:0.3];
                                               }
                                           }
                                           
                                       } failure:^(NSError *error) {
                                           [self showError:error];
                                           [self showLoadingView:NO];
                                       }];
}

- (void)fetchMore {
    
    if (!self.isFetching) {
        int count = self.items.count;
        if (count!=0) {
            if (self.page!=self.totalPages) {
                self.isFetching = YES;
                self.page++;
                [self fetchResource];
            }
        }
    }
}

- (void)restoreContentInset {
    [self.collectionView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
}

- (void)didFetchItems {
    
}

- (void)refresh {
    
}

- (void)showLoadingView:(BOOL)show {
    if (self.page==1) {
        if (show) {
            [self.refreshControl beginRefreshing];
        } else {
            [self.refreshControl endRefreshing];
        }
    } else {
        [self showLoadingView:show atBottomOfScrollView:YES];
    }
}

-(void)showError:(NSError *)error {
    self.isFetching = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Scroll View

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL isScrollDown = NO;
    if (lastOffset < scrollView.contentOffset.y) {
        isScrollDown = YES;
    }
    lastOffset = scrollView.contentOffset.y;
    if ([scrollView hasReachedBottom] && !self.isFetching && isScrollDown) {
        [self fetchMore];
    }
}

#pragma mark - Gesture

- (void)collectionViewPinched:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (gesture.scale > 1) {
            [self changeNumberOfColumnsWithPinch:PinchOut];
        } else {
            [self changeNumberOfColumnsWithPinch:PinchIn];
        }
    }
}

- (void)changeNumberOfColumnsWithPinch:(PinchDirection)direction {
    NSArray *visibleItems = [self.collectionView visibleCells];
    UICollectionViewCell *cell = visibleItems[0];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    int numCol = self.numberOfColumns;
    switch (direction) {
        case PinchIn:{
            self.numberOfColumns++;
            break;
        }
        case PinchOut:{
            self.numberOfColumns--;
            if (self.numberOfColumns==0) {
                self.numberOfColumns = 1;
            }
            break;
        }
        default:
            break;
    }
    if (numCol != self.numberOfColumns) {
        [self.collectionView performBatchUpdates:^{
            
        } completion:^(BOOL finished) {
            [self.collectionView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        }];
    }
    
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.frame);
    CGFloat width = (collectionViewWidth/(float)self.numberOfColumns);
    return CGSizeMake(width, width);
}

@end
