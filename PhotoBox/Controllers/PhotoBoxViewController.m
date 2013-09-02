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

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.items) {
        self.items = [NSMutableArray array];
    }
    if (self.page==0) {
        self.page = 1;
    }
    self.numberOfColumns = 2;
    
    [self setupConnectionManager];
    [self setupCollectionView];
    [self setupRefreshControl];
    [self setupPinchGesture];
    [self setupDataSource];
    [self setupNavigationItemTitle];
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

#pragma mark - Setup

- (void)setupConnectionManager {
    if (![[ConnectionManager sharedManager] baseURL]) {
#error Get your Consumer key, secret, oauth token, and secret in https://<username>.trovebox.com/manage/settings#apps
        
        [[ConnectionManager sharedManager] setBaseURL:[NSURL URLWithString:@"<YOUR_TROVEBOX_URL>"] // e.g. http://username.trovebox.com
                                          consumerKey:@"<YOUR_CONSUMER_KEY>"
                                       consumerSecret:@"<YOUR_CONSUMER_SECRET>"
                                           oauthToken:@"<YOUR_OAUTH_TOKEN>"
                                          oauthSecret:@"<YOUR_OAUTH_SECRET>"];
    }
}

- (void)setupCollectionView {
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setAlwaysBounceVertical:YES];
}

- (void)setupPinchGesture {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewPinched:)];
    [self.collectionView addGestureRecognizer:pinch];
}

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)setupDataSource {
    self.dataSource = [[CollectionViewDataSource alloc] init];
    self.collectionView.dataSource = self.dataSource;
    [self setupDataSourceConfigureBlock];
    if (self.items) {
        [self.dataSource setItems:self.items];
    }
}

- (void)setupDataSourceConfigureBlock {
    [self.dataSource setConfigureCellBlock:[self cellConfigureBlock]];
}

- (void)setupNavigationItemTitle {
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setNumberOfLines:2];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setAdjustsFontSizeToFitWidth:YES];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.navigationTitleLabel = titleLabel;
    [self.navigationItem setTitleView:self.navigationTitleLabel];
}

- (CollectionViewCellConfigureBlock)cellConfigureBlock {
    void (^configureCell)(PhotoBoxCell*, id) = ^(PhotoBoxCell* cell, id item) {
        [cell setItem:item];
    };
    return configureCell;
}

#pragma mark - Setter

- (void)setAttributedTitle:(NSAttributedString *)title {
    super.title = title.string;
    [self.navigationTitleLabel setAttributedText:title];
    [self.navigationTitleLabel sizeToFit];
}

- (void)setTitle:(NSString *)title subtitle:(NSString *)sub {
    NSString *combine = [NSString stringWithFormat:@"%@%@%@", title, (sub)?@"\n":@"", (sub)?:@""];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:combine];
    [string addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] range:[combine rangeOfString:title]];
    if (sub) {
        [string addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] range:[combine rangeOfString:sub]];
    }
    [self setAttributedTitle:string];
}

- (void)setTitle:(NSString *)title {
    [self setTitle:title subtitle:nil];
}

#pragma mark - Connection

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
