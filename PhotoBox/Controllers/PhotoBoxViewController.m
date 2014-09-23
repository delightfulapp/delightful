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
#import "Album.h"
#import "Tag.h"

#import "UIViewController+Additionals.h"
#import "UIScrollView+Additionals.h"
#import "NSArray+Additionals.h"

#import "DLFDatabaseManager.h"

#define INITIAL_PAGE_NUMBER 1

#define BATCH_SIZE 30

NSString *const galleryContainerType = @"gallery";

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
    
    [self.dataSource setDebugName:NSStringFromClass([self class])];
    
    self.page = INITIAL_PAGE_NUMBER;
    self.numberOfColumns = 2;
    _pageSize = BATCH_SIZE;
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self setupConnectionManager];
    [self setupCollectionView];
    [self setupRefreshControl];
    [self setupPinchGesture];
    [self setupNavigationItemTitle];
    
    if (!self.disableFetchOnLoad) {
        PBX_LOG(@"Gonna fetch resource in view did load");
        [self refreshIfNeeded];
    }
    
    [self restoreContentInset];
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
        if (![[[ConnectionManager sharedManager] baseURL] isEqual:[NSURL URLWithString:@"http://trovebox.com"]]) {
            if (![[ConnectionManager sharedManager] isUserLoggingIn]) {
                [[ConnectionManager sharedManager] setBaseURL:[NSURL URLWithString:@"http://trovebox.com"]
                                                  consumerKey:@"somerandomconsumerkey"
                                               consumerSecret:@"consumersecret"
                                                   oauthToken:nil
                                                  oauthSecret:nil];
            }
        } else {
            [[ConnectionManager sharedManager] setConsumerToken:[[AFOAuth1Token alloc] initWithKey:@"somerandomconsumerkey" secret:@"consumersecret" session:nil expiration:nil renewable:YES]];
        }
    }
    [[ConnectionManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(isUserLoggedIn)) options:0 context:NULL];
    [[ConnectionManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(isShowingLoginPage)) options:0 context:NULL];
    isObservingLoggedInUser = YES;
}

- (void)setupCollectionView {
    [self.collectionView setDelegate:self];
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
        _dataSource = [[[self dataSourceClass] alloc] initWithCollectionView:self.collectionView];
        [self setupDataSourceConfigureBlock];
        [_dataSource setCellIdentifier:self.cellIdentifier];
        [_dataSource setSectionHeaderIdentifier:[self sectionHeaderIdentifier]];
        [_dataSource setConfigureCellHeaderBlock:[self headerCellConfigureBlock]];
    }
    return _dataSource;
}

- (Class)dataSourceClass {
    return [CollectionViewDataSource class];
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

- (NSString *)displayedItemIdKey {
    NSString *itemClassName = [NSStringFromClass([self resourceClass]) lowercaseString];
    return [NSString stringWithFormat:@"%@Id", itemClassName];
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingView setHidesWhenStopped:YES];
    }
    return _loadingView;
}

- (NSString *)fetchedInIdentifier {
    if ([self isGallery]) {
        return galleryContainerType;
    }
    return [[self relationshipKeyPathWithItem] stringByAppendingFormat:@"-%@", [self.item itemId]];
}

- (NSString *)groupKey {
    return nil;
}

- (NSPredicate *)predicate {
    return nil;
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
    if (!title) {
        super.title = nil;
        return;
    }
    [self setTitle:title subtitle:nil];
}

#pragma mark - Connection

- (void)fetchResource {
    return;
    [self showLoadingView:YES];
    PBX_LOG(@"Fetching resource: %@", NSStringFromClass(self.resourceClass));
    [[PhotoBoxClient sharedClient] getResource:self.resourceType
                                        action:ListAction
                                    resourceId:self.resourceId
                                     fetchedIn:[self fetchedInIdentifier]
                                          page:self.page
                                      pageSize:self.pageSize mainContext:nil
                                       success:^(id objects) {
                                           [self showLoadingView:NO];
                                           if (objects) {
                                               if (self.refreshControl.isRefreshing) {
                                                   self.collectionView.contentInset = ({
                                                       UIEdgeInsets inset = self.collectionView.contentInset;
                                                       inset.top += self.refreshControl.frame.size.height;
                                                       inset;
                                                   });
                                                   [self.refreshControl endRefreshing];
                                                   [self restoreContentInset];
                                                   
                                               }
                                               PBX_LOG(@"Received %lu %@. Total shown = %ld", (unsigned long)((NSArray *)objects).count, NSStringFromClass(self.resourceClass), (long)[self.dataSource numberOfItems]);
                                               [self processPaginationFromObjects:objects];
                                               
                                               self.isFetching = NO;
                                               
                                               [self.dataSource addItems:objects];
                                               
                                               [self didFetchItems];
                                                                                              
                                               NSInteger count = [self.dataSource numberOfItems];
                                               if (count==self.totalItems) {
                                                   [self performSelector:@selector(restoreContentInset) withObject:nil afterDelay:0.3];
                                               }
                                           }
                                           
                                       } failure:^(NSError *error) {
                                           PBX_LOG(@"Error: %@", error);
                                           [self showError:error];
                                           [self showLoadingView:NO];
                                       }];
}

- (void)fetchMore {
    if (!self.isFetching) {
        NSInteger count = [self.dataSource numberOfItems];
        if (count>0) {
            if (self.page!=self.totalPages) {
                self.isFetching = YES;
                self.page = ((int)count/(int)self.pageSize)+1;
                PBX_LOG(@"Fetch more");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showLoadingView:YES];
                });
                [self performSelector:@selector(fetchResource) withObject:nil afterDelay:0.5];
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
    } else {
        self.totalItems = (int)((NSArray *)objects).count;
        self.totalPages = 1;
        self.currentPage = 1;
        self.currentRow = 0;
    }
}

- (void)restoreContentInset {
    PBX_LOG(@"");
    [self.collectionView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
}

- (void)didFetchItems {
    
}

- (void)refresh {
    PBX_LOG(@"Refresh %@", NSStringFromClass(self.resourceClass));
    self.isFetching = YES;
    self.page = INITIAL_PAGE_NUMBER;
    [self.collectionView reloadData];
    [self fetchResource];
}

- (void)refreshIfNeeded {
    [self refresh];
}

- (NSString *)refreshKey {
    return nil;
}

- (NSArray *)cachedItems {
    return nil;
}

- (void)willLoadDataFromCache {
    
}

- (void)didLoadDataFromCache {
    
}

- (void)showLoadingView:(BOOL)show {
    if (self.page==INITIAL_PAGE_NUMBER) {
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

- (void)userDidLogout {
    
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
            self.numberOfColumns = MIN(self.numberOfColumns, 10);
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
        if (self.numberOfColumns == 1) {
            [self.collectionView.collectionViewLayout invalidateLayout];
        }
        [self.collectionView performBatchUpdates:^{
            
        } completion:^(BOOL finished) {
            [self didChangeNumberOfColumns];
            [self restoreContentInset];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        }];
    }
}

- (void)didChangeNumberOfColumns {
    
}

#pragma mark - Photos page stuff

- (BOOL)isGallery {
    return ([self.item.itemId isEqualToString:PBX_allAlbumIdentifier])?YES:NO;
}

- (NSArray *)sortDescriptors {
    NSMutableArray *sorts = [NSMutableArray array];
    
    if ([self isGallery]) {
        NSSortDescriptor *uploadedSort = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(dateUploaded)) ascending:NO];
        [sorts addObject:uploadedSort];
    }
    
    NSSortDescriptor *dateTakenStringSort = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(dateTakenString)) ascending:NO];
    [sorts addObject:dateTakenStringSort];
    
    NSSortDescriptor *dateTakenSort = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(dateTaken)) ascending:YES];
    [sorts addObject:dateTakenSort];
    
    return sorts;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.numberOfColumns <= 1) {
        return CGSizeZero;
    }
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.frame);
    CGFloat width = floorf((collectionViewWidth/(float)self.numberOfColumns));
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ((int)CGRectGetWidth(self.collectionView.frame)%self.numberOfColumns == 0 && self.numberOfColumns != 1) {
        return 0;
    } else if (self.numberOfColumns == 1) {
        return 5;
    }
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[ConnectionManager class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(isUserLoggedIn))]) {
            BOOL userLoggedIn = [[ConnectionManager sharedManager] isUserLoggedIn];
            if (userLoggedIn) {
                PBX_LOG(@"Gonna fetch resource in KVO");
                [self fetchResource];
            } else {
                NSLog(@"Logging out, clearing everything");
                [[DLFDatabaseManager manager] removeAllItems];
                self.page = INITIAL_PAGE_NUMBER;
                [self.collectionView reloadData];
                [self userDidLogout];
            }
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(isShowingLoginPage))]) {
            if ([[ConnectionManager sharedManager] isShowingLoginPage]) {
                self.isFetching = NO;
            }
        }
    }
}

@end
