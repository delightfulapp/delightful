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

#define INITIAL_PAGE_NUMBER 1

@interface PhotoBoxViewController () <UICollectionViewDelegateFlowLayout, UIAlertViewDelegate> {
    CGFloat lastOffset;
    BOOL isObservingLoggedInUser;
}

@property (nonatomic, assign, getter = isShowingAlert) BOOL showingAlert;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation PhotoBoxViewController

@synthesize pageSize = _pageSize;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.page = INITIAL_PAGE_NUMBER;
    self.numberOfColumns = 2;
    _pageSize = 20;
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self setupConnectionManager];
    [self setupCollectionView];
    [self setupRefreshControl];
    [self setupPinchGesture];
    [self setupNavigationItemTitle];
    
    if (!self.disableFetchOnLoad) {
        [self performSelector:@selector(fetchResource) withObject:nil afterDelay:1];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PBX_LOG(@"Resuming %@ data source.", NSStringFromClass(self.resourceClass));
    self.dataSource.paused = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    PBX_LOG(@"Pausing %@ data source.", NSStringFromClass(self.resourceClass));
    if (![[ConnectionManager sharedManager] isShowingLoginPage]) {
        // no need to pause data source when login page is showing
        self.dataSource.paused = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (isObservingLoggedInUser) {
        [[ConnectionManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(isUserLoggedIn))];
        [[ConnectionManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(isShowingLoginPage))];
    }
}

#pragma mark - Orientation

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
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
    isObservingLoggedInUser = YES;
}

- (void)setupCollectionView {
    [self.collectionView setContentInset:UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame), 0, 0, 0)];
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
        NSLog(@"Create data source");
        _dataSource = [[CollectionViewDataSource alloc] initWithCollectionView:self.collectionView];
        [_dataSource setFetchedResultsController:self.fetchedResultsController];
        [self setupDataSourceConfigureBlock];
        [_dataSource setCellIdentifier:self.cellIdentifier];
        [_dataSource setSectionHeaderIdentifier:[self sectionHeaderIdentifier]];
        [_dataSource setConfigureCellHeaderBlock:[self headerCellConfigureBlock]];
        
        [_dataSource setDebugName:NSStringFromClass([self class])];
    }
    return _dataSource;
}

- (NSManagedObjectContext *)mainContext {
    if (!_mainContext) {
        NSLog(@"create main context");
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
        NSLog(@"create fetch request");
        _fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[PhotoBoxModel photoBoxManagedObjectEntityNameForClassName:NSStringFromClass(self.resourceClass)]];
        [_fetchRequest setSortDescriptors:self.sortDescriptors];
        if (self.predicate) {
            [_fetchRequest setPredicate:self.predicate];
        }
        [_fetchRequest setFetchLimit:self.pageSize];
    }
    return _fetchRequest;
}

- (NSPredicate *)predicate {
    if (self.item && ![self isGallery]) {
        if (!_predicate) {
            NSLog(@"create predicate");
            _predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS %@", [NSString stringWithFormat:@"%@", self.relationshipKeyPathWithItem], [NSString stringWithFormat:@"%@%@%@", ARRAY_SEPARATOR, self.item.itemId, ARRAY_SEPARATOR]];
        }
        return _predicate;
    }
    return nil;
}

- (PhotoBoxFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSLog(@"create fetch result controller");
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

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingView setHidesWhenStopped:YES];
    }
    return _loadingView;
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
    
    PBX_LOG(@"Fetching resource: %@", NSStringFromClass(self.resourceClass));
    [[PhotoBoxClient sharedClient] getResource:self.resourceType
                                        action:ListAction
                                    resourceId:self.resourceId
                                          page:self.page
                                      pageSize:self.pageSize
                                       success:^(id objects) {
                                           [self showLoadingView:NO];
                                           if (objects) {
                                               PBX_LOG(@"Received %d %@. Total = %d", ((NSArray *)objects).count, NSStringFromClass(self.resourceClass), [self.dataSource numberOfItems]);
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
        PBX_LOG(@"Photos count = %d", count);
        if (count!=0) {
            if (self.page!=self.totalPages) {
                self.isFetching = YES;
                self.page++;
                
                [self loadItemsFromCoreData];
                
                [self performSelector:@selector(fetchResource) withObject:nil afterDelay:0.5];
            }
        }
    }
}

- (void)loadItemsFromCoreData {
    PBX_LOG(@"");
    [self.dataSource.fetchedResultsController.fetchRequest setFetchLimit:self.page*self.pageSize];
    [self.dataSource.fetchedResultsController performFetch:NULL];
    PBX_LOG(@"Reloading coleection view");
    [self.collectionView reloadData];
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
    PBX_LOG(@"");
    [self.collectionView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
}

- (void)didFetchItems {
    
}

- (void)refresh {
    PBX_LOG(@"Refresh %@", NSStringFromClass(self.resourceClass));
    self.page = INITIAL_PAGE_NUMBER;
    [self loadItemsFromCoreData];
    [self fetchResource];
}

- (void)showLoadingView:(BOOL)show {
    if (self.page==1) {
        if (show) {
            if (!self.navigationItem.rightBarButtonItem) {
                UIBarButtonItem *loadingItem = [[UIBarButtonItem alloc] initWithCustomView:self.loadingView];
                [self.navigationItem setRightBarButtonItem:loadingItem];
            }
            [self.loadingView startAnimating];
            PBX_LOG(@"Showing right loading view");
        } else {
            [self.loadingView stopAnimating];
            PBX_LOG(@"Stopping right loading view");
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
                PBX_LOG(@"End refresh control");
            }
        }
        [self showLoadingView:show atBottomOfScrollView:YES];
        PBX_LOG(@"Showing bottom loading view");
    } else {
        [self showLoadingView:show atBottomOfScrollView:YES];
        PBX_LOG(@"Closing bottom loading view");
    }
}

-(void)showError:(NSError *)error {
    self.isFetching = NO;
    if (!self.showingAlert) {
        self.showingAlert = YES;
        PBX_LOG(@"Showing error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.showingAlert = NO;
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
    PBX_LOG(@"Pinched %@. Number of columns = %d", NSStringFromClass(self.resourceClass), self.numberOfColumns);
}

- (void)changeNumberOfColumnsWithPinch:(PinchDirection)direction {
    PBX_LOG(@"");
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

#pragma mark - Photos page stuff

- (BOOL)isGallery {
    return ([self.item.itemId isEqualToString:PBX_allAlbumIdentifier])?YES:NO;
}

- (NSArray *)sortDescriptors {
    NSMutableArray *sorts = [NSMutableArray array];
    
    NSSortDescriptor *dateTakenStringSort = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(dateTakenString)) ascending:NO];
    [sorts addObject:dateTakenStringSort];
    
    NSSortDescriptor *dateTakenSort = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(dateTaken)) ascending:YES];
    [sorts addObject:dateTakenSort];
    
    if ([self isGallery]) {
        NSSortDescriptor *uploadedSort = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(dateUploaded)) ascending:NO];
        [sorts addObject:uploadedSort];
    }
    
    return sorts;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.frame);
    CGFloat width = floorf((collectionViewWidth/(float)self.numberOfColumns));

    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ((int)CGRectGetWidth(self.collectionView.frame)%self.numberOfColumns == 0 && self.numberOfColumns != 1) {
        return 0;
    }
    return 1;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[ConnectionManager class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(isUserLoggedIn))]) {
            BOOL userLoggedIn = [[ConnectionManager sharedManager] isUserLoggedIn];
            if (userLoggedIn) {
                [self fetchResource];
            } else {
                self.dataSource = nil;
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
