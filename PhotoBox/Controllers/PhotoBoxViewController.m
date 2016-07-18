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
#import "StickyHeaderFlowLayout.h"
#import "NSAttributedString+DelighftulFonts.h"
#import "LoadingNavigationItemTitleView.h"
#import "DLFDatabaseManager.h"
#import "SyncEngine.h"

#import "PureLayout.h"

#define INITIAL_PAGE_NUMBER 1

#define BATCH_SIZE 30

NSString *const galleryContainerType = @"gallery";


@interface PhotoBoxViewController () <UICollectionViewDelegateFlowLayout, UIAlertViewDelegate> {
    CGFloat lastOffset;
    BOOL isObservingLoggedInUser;
}

@property (nonatomic, assign, getter = isShowingAlert) BOOL showingAlert;
@property (nonatomic, assign) CGSize currentSize;
@property (nonatomic, assign) BOOL _showRightBarButtonItem;
@property (nonatomic, strong) NSValue *contentSize;
@property (nonatomic, strong) UIActivityIndicatorView *bottomLoadingView;

@end

@implementation PhotoBoxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showEmptyLoading:YES];
    
    [self.collectionView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    self.currentSize = self.view.frame.size;
    
    [self.dataSource setDebugName:NSStringFromClass([self class])];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self setupConnectionManager];
    [self setupCollectionView];
    [self setupRefreshControl];
    [self setupNavigationItemTitle];
    
    [self.collectionView reloadData];
    
    [self restoreContentInset];
    
    [self setRegisterSyncingNotification:YES];
}

- (void)setRegisterSyncingNotification:(BOOL)registerSyncingNotification {
    if (_registerSyncingNotification != registerSyncingNotification) {
        _registerSyncingNotification = registerSyncingNotification;
        
        if (registerSyncingNotification) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willStartSyncingNotification:) name:SyncEngineWillStartFetchingNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishSyncingNotification:) name:SyncEngineDidFinishFetchingNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailSyncingNotification:) name:SyncEngineDidFailFetchingNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:SyncEngineWillStartFetchingNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:SyncEngineDidFinishFetchingNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:SyncEngineDidFailFetchingNotification object:nil];
        }
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [self setRegisterSyncingNotification:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setRegisterSyncingNotification:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.collectionView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
    if (isObservingLoggedInUser) {
        [[ConnectionManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(isUserLoggedIn))];
        [[ConnectionManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(isShowingLoginPage))];
    }
}

- (void)restoreContentInset {
    
}

- (void)showEmptyLoading:(BOOL)show {
    [self showEmptyLoading:show withText:nil];
}

- (void)showEmptyLoading:(BOOL)show withText:(id)text {
    if (show) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
        [self.collectionView setBackgroundView:view];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[view viewWithTag:20000];
        if (!indicator) {
            indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [indicator setCenter:CGPointMake(CGRectGetWidth(view.frame)/2, CGRectGetHeight(view.frame)/2)];
            [indicator setTag:20000];
            [view addSubview:indicator];
            [indicator startAnimating];
            [indicator setTranslatesAutoresizingMaskIntoConstraints:NO];
            [indicator autoCenterInSuperview];
        }
        
        if (text) {
            UILabel *textLabel = (UILabel *)[view viewWithTag:10000];
            if (!textLabel) {
                textLabel = [[UILabel alloc] initForAutoLayout];
                [textLabel setNumberOfLines:0];
                [textLabel setTag:10000];
                [view addSubview:textLabel];
                [textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:view withOffset:20];
                [textLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:view withOffset:-20];
                [textLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:indicator withOffset:10];
            }
            
            if ([text isKindOfClass:[NSAttributedString class]]) {
                [textLabel setAttributedText:text];
            } else {
                [textLabel setText:text];
                [textLabel setTextColor:[UIColor lightGrayColor]];
                [textLabel setFont:[UIFont systemFontOfSize:12]];
                [textLabel setTextAlignment:NSTextAlignmentCenter];
            }
            [textLabel sizeToFit];
        } else {
            UILabel *textLabel = (UILabel *)[view viewWithTag:10000];
            if (textLabel) {
                [textLabel setText:nil];
            }
        }
    } else {
        [self.collectionView setBackgroundView:nil];
        //[self.collectionView setAlwaysBounceVertical:YES];
    }
}

- (void)showNoItems:(BOOL)show {
    if (show) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
        [self.collectionView setBackgroundView:view];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *textLabel = (UILabel *)[view viewWithTag:10000];
        if (!textLabel) {
            textLabel = [[UILabel alloc] initForAutoLayout];
            [textLabel setNumberOfLines:0];
            [textLabel setTag:10000];
            [view addSubview:textLabel];
            [textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:view withOffset:20];
            [textLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:view withOffset:-20];
            [textLabel autoCenterInSuperview];
        }
        
        [textLabel setText:NSLocalizedString(@"No Photos", nil)];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [textLabel setFont:[UIFont systemFontOfSize:12]];
        [textLabel setTextColor:[UIColor lightGrayColor]];
    } else {
        [self.collectionView setBackgroundView:nil];
    }
}


- (void)showRightBarButtonItem:(BOOL)show {
    if (__showRightBarButtonItem != show) {
        __showRightBarButtonItem = show;
        if (show) {
            if (!self.navigationItem.rightBarButtonItem) {
                UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapSortButton:)];
                [self.navigationItem setRightBarButtonItem:leftItem];
            }
        } else {
            [self.navigationItem setRightBarButtonItem:nil];
        }
    }
}

- (void)didTapSortButton:(id)sender {
}

#pragma mark - Orientation

- (void)dlf_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    CLS_LOG(@"**** will transition to size %@ in %@", NSStringFromCGSize(size), self.class);
    
    if ([self.collectionView.collectionViewLayout respondsToSelector:@selector(targetIndexPath)]) {
        self.currentSize = size;
        
        NSIndexPath *indexPath;
        NSArray *visibleCell = [self.collectionView visibleCells];
        CGFloat minimumVisibleY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
        for (UICollectionViewCell *cell in visibleCell) {
            if (cell.frame.origin.y > minimumVisibleY) {
                if (!indexPath) {
                    indexPath = [self.collectionView indexPathForCell:cell];
                } else {
                    NSIndexPath *thisIndexPath = [self.collectionView indexPathForCell:cell];
                    NSComparisonResult result = [thisIndexPath compare:indexPath];
                    if (result == NSOrderedAscending) {
                        indexPath = thisIndexPath;
                    }
                }
            }
        }
        
        if (self.selectedCell) {
            [((id)self.collectionView.collectionViewLayout) setTargetIndexPath:[self.collectionView indexPathForCell:self.selectedCell]];
        } else {
            [((id)self.collectionView.collectionViewLayout) setTargetIndexPath:(indexPath)?indexPath:[self.collectionView indexPathForCell:[[self.collectionView visibleCells] firstObject]]];
        }
    }
    
    BOOL needToRestoreOffset = NO;
    if (self.collectionView.contentOffset.y == -self.collectionView.contentInset.top) {
        needToRestoreOffset = YES;
    }
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self restoreContentInsetForSize:size];
        [self.collectionView.collectionViewLayout invalidateLayout];
        if (needToRestoreOffset) {
            self.collectionView.contentOffset = CGPointMake(0, -self.collectionView.contentInset.top);
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
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
    [self.collectionView setContentInset:UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0)];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setAlwaysBounceVertical:YES];
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
        [_dataSource setLoadingFooterIdentifier:[self footerIdentifier]];
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

- (UICollectionViewCell *)selectedCell {
    NSIndexPath *indexPath = [self.dataSource indexPathOfItem:self.selectedItem];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    return cell;
}

#pragma mark - Setter

- (void)setIsFetching:(BOOL)isFetching {
    if (_isFetching != isFetching) {
        _isFetching = isFetching;
        if (!isFetching) {
            [self.collectionView reloadData];
            self.navigationItem.titleView = nil;
        } else {
            LoadingNavigationItemTitleView *loadingItemTitleView = (LoadingNavigationItemTitleView *)self.navigationItem.titleView;
            if (!loadingItemTitleView || ![loadingItemTitleView isKindOfClass:[LoadingNavigationItemTitleView class]]) {
                loadingItemTitleView = [[LoadingNavigationItemTitleView alloc] initWithFrame:CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX)];
                [loadingItemTitleView.titleLabel setText:self.title];
                [loadingItemTitleView.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
                CGSize size = [loadingItemTitleView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
                loadingItemTitleView.frame = (CGRect){loadingItemTitleView.frame.origin, size};
                loadingItemTitleView.center = CGPointMake(self.navigationController.navigationBar.frame.size.width/2, self.navigationController.navigationBar.frame.size.height/2);
                [self.navigationItem setTitleView:loadingItemTitleView];
            }
            if (!loadingItemTitleView.indicatorView.isAnimating) {
                [loadingItemTitleView.indicatorView startAnimating];
            }
        }
        if ([self.collectionView.collectionViewLayout isKindOfClass:[StickyHeaderFlowLayout class]]) {
            [((StickyHeaderFlowLayout *)self.collectionView.collectionViewLayout) setShowLoadingView:isFetching];
        }
    }
    
    if (isFetching) {
        if (!self.bottomLoadingView) {
            self.bottomLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        self.bottomLoadingView.center = CGPointMake(CGRectGetWidth(self.collectionView.frame)/2, self.collectionView.contentSize.height - CGRectGetHeight(self.bottomLoadingView.frame)/2 - 10);
        [self.collectionView insertSubview:self.bottomLoadingView atIndex:0];
        if (![self.bottomLoadingView isAnimating]) [self.bottomLoadingView startAnimating];
    } else {
        [self.bottomLoadingView removeFromSuperview];
    }
}

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

- (void)restoreContentInsetForSize:(CGSize)size {
    [self.collectionView setContentInset:UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame), 0, 0, 0)];
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
}

- (void)refresh {
}

-(void)showError:(NSError *)error {
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




- (void)didChangeNumberOfColumns {
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[ConnectionManager class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(isUserLoggedIn))]) {
            BOOL userLoggedIn = [[ConnectionManager sharedManager] isUserLoggedIn];
            if (userLoggedIn) {
                PBX_LOG(@"Gonna fetch resource in KVO");
                [self showSyncingLoadingMessageIfNeeded];
            } else {
                CLS_LOG(@"Logging out, clearing everything");
                [[DLFDatabaseManager manager] removeAllItems];
                [self.collectionView reloadData];
                [self userDidLogout];
            }
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(isShowingLoginPage))]) {
            if ([[ConnectionManager sharedManager] isShowingLoginPage]) {
            }
        }
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        if (!CGSizeEqualToSize(self.contentSize.CGSizeValue, [change[@"new"] CGSizeValue])) {
            self.contentSize = change[@"new"];
            
            if ([self.dataSource numberOfItems] > 0) {
                [self showEmptyLoading:NO];
                [self showRightBarButtonItem:YES];
            } else {
                if (![self showSyncingLoadingMessageIfNeeded]) {
                    [self showEmptyLoading:YES];
                }
                [self showRightBarButtonItem:NO];
                if (self.isDoneSyncing) {
                    [self showEmptyLoading:NO];
                    [self showNoItems:YES];
                }
                
            }
        }
    }
}

#pragma mark - Sync Engine Notification

- (BOOL)showSyncingLoadingMessageIfNeeded {
    return NO;
}

- (void)willStartSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    NSString *item = userInfo[SyncEngineNotificationIdentifierKey];
    if ([item isKindOfClass:[NSNull class]]) {
        item = nil;
    }
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])] && !item) {
        [self setIsFetching:YES];
    }
}

- (void)didFinishSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    NSString *item = userInfo[SyncEngineNotificationIdentifierKey];
    if ([item isKindOfClass:[NSNull class]]) {
        item = nil;
    }
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])] && !item) {
        NSNumber *count = userInfo[SyncEngineNotificationCountKey];
        if (count.intValue == 0) {
            [self setIsFetching:NO];
        }
    }
}

- (void)didFailSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    NSString *item = userInfo[SyncEngineNotificationIdentifierKey];
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])] && !item) {
        [self setIsFetching:NO];
    }
}

@end
