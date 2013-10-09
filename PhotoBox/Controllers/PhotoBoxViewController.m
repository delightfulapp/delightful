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
#import "Photo.h"

#import "UIViewController+Additionals.h"
#import "UIScrollView+Additionals.h"
#import "NSArray+Additionals.h"

@interface PhotoBoxViewController () <UICollectionViewDelegateFlowLayout> {
    CGFloat lastOffset;
}

@property (nonatomic, assign, readonly) int pageSize;

@end

@implementation PhotoBoxViewController

@synthesize pageSize = _pageSize;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.page==0) {
        self.page = 1;
    }
    self.numberOfColumns = 2;
    
    [self setupConnectionManager];
    [self setupCollectionView];
    [self setupRefreshControl];
    [self setupPinchGesture];
    [self setupNavigationItemTitle];
    
    [self performSelector:@selector(fetchResource) withObject:nil afterDelay:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataSource.paused = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.dataSource.paused = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[ConnectionManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(isUserLoggedIn))];
}

#pragma mark - Setup

- (void)setupConnectionManager {
    if (![[ConnectionManager sharedManager] isUserLoggedIn]) {
        [[ConnectionManager sharedManager] setBaseURL:[NSURL URLWithString:@"http://trovebox.com"]
                                          consumerKey:@"somerandomconsumerkey"
                                       consumerSecret:@"consumersecret"
                                           oauthToken:nil
                                          oauthSecret:nil];
    }
    [[ConnectionManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(isUserLoggedIn)) options:0 context:NULL];
    [[ConnectionManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(isShowingLoginPage)) options:0 context:NULL];
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

#pragma mark - Getter

- (CollectionViewDataSource *)dataSource {
    if (!_dataSource) {
        self.dataSource = [[CollectionViewDataSource alloc] initWithCollectionView:self.collectionView];
        [_dataSource setFetchedResultsController:self.fetchedResultsController];
        [self setupDataSourceConfigureBlock];
        [_dataSource setCellIdentifier:self.cellIdentifier];
        [_dataSource setSectionHeaderIdentifier:[self sectionHeaderIdentifier]];
        [_dataSource setConfigureCellHeaderBlock:[self headerCellConfigureBlock]];
    }
    return _dataSource;
}

- (NSManagedObjectContext *)mainContext {
    if (!_mainContext) {
        _mainContext = [NSManagedObjectContext mainContext];
    }
    return _mainContext;
}

- (CollectionViewCellConfigureBlock)cellConfigureBlock {
    void (^configureCell)(PhotoBoxCell*, id) = ^(PhotoBoxCell* cell, id item) {
        [cell setItem:item];
    };
    return configureCell;
}

- (CollectionViewHeaderCellConfigureBlock)headerCellConfigureBlock {
    return nil;
}

- (NSFetchRequest *)fetchRequest {
    if (!_fetchRequest) {
        _fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[PhotoBoxModel photoBoxManagedObjectEntityNameForClassName:NSStringFromClass(self.resourceClass)]];
        [_fetchRequest setSortDescriptors:self.sortDescriptors];
        if (self.predicate) {
            [_fetchRequest setPredicate:self.predicate];
        }
    }
    return _fetchRequest;
}

- (NSPredicate *)predicate {
    if (self.item && ![self.item.itemId isEqualToString:PBX_allAlbumIdentifier]) {
        if (!_predicate) {
            _predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS %@", [NSString stringWithFormat:@"%@", self.relationshipKeyPathWithItem], [NSString stringWithFormat:@"%@%@%@", ARRAY_SEPARATOR, self.item.itemId, ARRAY_SEPARATOR]];
        }
        return _predicate;
    }
    return nil;
}

- (PhotoBoxFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        _fetchedResultsController = [[PhotoBoxFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.mainContext sectionNameKeyPath:[self groupKey] cacheName:nil];
        [_fetchedResultsController setObjectClass:self.resourceClass];
        [_fetchedResultsController setItemKey:self.displayedItemIdKey];
    }
    return _fetchedResultsController;
}

- (NSString *)displayedItemIdKey {
    NSString *itemClassName = [NSStringFromClass([self resourceClass]) lowercaseString];
    return [NSString stringWithFormat:@"%@Id", itemClassName];
}

- (NSArray *)items {
    return self.fetchedResultsController.fetchedObjects;
}

- (int)pageSize {
    if (self.page == 1) {
        _pageSize = 20;
        if (self.fetchedResultsController.fetchedObjects.count > 0) {
            _pageSize = self.fetchedResultsController.fetchedObjects.count;
        }
    }
    return _pageSize;
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
                                      pageSize:self.pageSize
                                       success:^(id objects) {
                                           [self showLoadingView:NO];
                                           if (objects) {
                                               NSLog(@"Received %d objects", ((NSArray *)objects).count);
                                               [self processPaginationFromObjects:objects];
                                               
                                               self.isFetching = NO;
                                               
                                               [self didFetchItems];
                                               
                                               int count = [self.dataSource numberOfItems];
                                               if (count==self.totalItems) {
                                                   [self performSelector:@selector(restoreContentInset) withObject:nil afterDelay:0.3];
                                               }
                                           }
                                           
                                       } failure:^(NSError *error) {
                                           [self showError:error];
                                           [self showLoadingView:NO];
                                       }];
}

- (void)fetchMore {
    if (!self.isFetching) {
        int count = [self.dataSource numberOfItems];
        if (count!=0) {
            if (self.page!=self.totalPages) {
                self.isFetching = YES;
                self.page++;
                [self fetchResource];
            }
        }
    }
}

- (void)processPaginationFromObjects:(id)objects {
    NSArray *filtered = [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"totalRows > 0"]];
    if (filtered.count == 1) {
        PhotoBoxModel *firstObject = (PhotoBoxModel *)[filtered firstObject];
        self.totalItems = [firstObject.totalRows intValue];
        self.totalPages = [firstObject.totalPages intValue];
        self.currentPage = [firstObject.currentPage intValue];
        self.currentRow = [firstObject.currentRow intValue];
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
            [self.refreshControl setHidden:NO];
        } else {
            [self.refreshControl endRefreshing];
            [self.collectionView.collectionViewLayout invalidateLayout];
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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[ConnectionManager class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(isUserLoggedIn))]) {
            BOOL userLoggedIn = [[ConnectionManager sharedManager] isUserLoggedIn];
            if (userLoggedIn) {
                [self fetchResource];
            } else {
                self.page = 1;
                self.fetchedResultsController = nil;
                self.fetchRequest = nil;
                self.predicate = nil;
                self.mainContext = nil;
                self.dataSource = nil;
            }
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(isShowingLoginPage))]) {
            if ([[ConnectionManager sharedManager] isShowingLoginPage]) {
                self.isFetching = NO;
            }
        }
    }
}

@end
