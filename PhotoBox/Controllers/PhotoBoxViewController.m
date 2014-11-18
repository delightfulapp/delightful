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

#import "DLFDatabaseManager.h"
#import "SyncEngine.h"

#import <UIView+AutoLayout.h>

#define INITIAL_PAGE_NUMBER 1

#define BATCH_SIZE 30

NSString *const galleryContainerType = @"gallery";


@interface PhotoBoxViewController () <UICollectionViewDelegateFlowLayout, UIAlertViewDelegate> {
    CGFloat lastOffset;
    BOOL isObservingLoggedInUser;
}

@property (nonatomic, assign, getter = isShowingAlert) BOOL showingAlert;
@property (nonatomic, assign) CGSize currentSize;

@end

@implementation PhotoBoxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showEmptyLoading:YES];
    
    [self.collectionView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    self.currentSize = self.view.frame.size;
    
    [self.dataSource setDebugName:NSStringFromClass([self class])];
    
    self.numberOfColumns = 3;
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self setupConnectionManager];
    [self setupCollectionView];
    [self setupRefreshControl];
    [self setupPinchGesture];
    [self setupNavigationItemTitle];
    
    [self.collectionView reloadData];
    
    [self restoreContentInset];
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
        UIView *view = self.collectionView.backgroundView;
        
        if (!view) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
            [self.collectionView setBackgroundView:view];
            [view setBackgroundColor:[UIColor whiteColor]];
        }
        
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



- (void)showRightBarButtonItem:(BOOL)show {
    if (show) {
        UIButton *sortingButton = [[UIButton alloc] init];
        NSMutableAttributedString *sortingSymbol = [[NSAttributedString symbol:dlf_icon_menu_sort size:25] mutableCopy];
        [sortingButton setAttributedTitle:sortingSymbol forState:UIControlStateNormal];
        [sortingButton sizeToFit];
        [sortingButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
        [sortingButton addTarget:self action:@selector(didTapSortButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:sortingButton];
        [self.navigationItem setRightBarButtonItem:leftItem];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (void)didTapSortButton:(id)sender {
}

#pragma mark - Orientation

- (void)dlf_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    CLS_LOG(@"**** will transition to size %@ in %@", NSStringFromCGSize(size), self.class);
    if ([self.collectionView.collectionViewLayout isKindOfClass:[StickyHeaderFlowLayout class]]) {
        self.currentSize = size;
        
        CGFloat originYRectToExamine = self.collectionView.contentOffset.y + CGRectGetMaxY(self.navigationController.navigationBar.frame) + 44;
        NSIndexPath *indexPath;
        for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
            NSIndexPath *ind = [self.collectionView indexPathForCell:cell];
            
            UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:ind];
            if (attr.frame.origin.y > originYRectToExamine-5) {
                if (!indexPath) {
                    indexPath = ind;
                } else {
                    if ([indexPath compare:ind] == NSOrderedDescending) {
                        indexPath = ind;
                    }
                }
            }
        }
        
        if (self.selectedCell) {
            [((StickyHeaderFlowLayout *)self.collectionView.collectionViewLayout) setTargetIndexPath:[self.collectionView indexPathForCell:self.selectedCell]];
        } else {
            [((StickyHeaderFlowLayout *)self.collectionView.collectionViewLayout) setTargetIndexPath:(indexPath)?indexPath:[self.collectionView indexPathForCell:[[self.collectionView visibleCells] firstObject]]];
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

- (NSInteger)numberOfColumnsForCurrentSize {
    if (self.currentSize.width < self.currentSize.height) {
        return self.numberOfColumns;
    }
    return MAX(self.numberOfColumns * 2 - 1, 1);
}

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

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.numberOfColumns <= 1) {
        return CGSizeZero;
    }
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.frame);
    CGFloat width = floorf(((collectionViewWidth - ([self numberOfColumnsForCurrentSize]-1))/(float)[self numberOfColumnsForCurrentSize]));
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[ConnectionManager class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(isUserLoggedIn))]) {
            BOOL userLoggedIn = [[ConnectionManager sharedManager] isUserLoggedIn];
            if (userLoggedIn) {
                PBX_LOG(@"Gonna fetch resource in KVO");
                [[SyncEngine sharedEngine] initialize];
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
        if ([self.dataSource numberOfItems] > 0) {
            [self showEmptyLoading:NO];
            [self showRightBarButtonItem:YES];
        } else {
            if (![self showSyncingLoadingMessageIfNeeded]) {
                [self showEmptyLoading:YES];
            }
            [self showRightBarButtonItem:NO];
        }
    }
}

#pragma mark - Sync Engine Notification

- (void)setIsFetching:(BOOL)isFetching {
    _isFetching = isFetching;
    if (!isFetching) {
        [self.collectionView reloadData];
    }
}

- (BOOL)showSyncingLoadingMessageIfNeeded {
    return NO;
}

- (void)willStartSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])]) {
        NSLog(@"will start syncing");
        [self setIsFetching:YES];
    }
}

- (void)didFinishSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])]) {
        NSLog(@"did finish syncing");
        NSNumber *count = userInfo[SyncEngineNotificationCountKey];
        if (count.intValue == 0) {
            [self setIsFetching:NO];
        }
    }
}

- (void)didFailSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])]) {
        [self setIsFetching:NO];
    }
}

@end
