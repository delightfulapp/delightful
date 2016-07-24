//
//  FavoritesViewController.m
//  Delightful
//
//  Created by  on 11/16/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "FavoritesViewController.h"
#import "GroupedPhotosDataSource.h"
#import "FavoritesManager.h"
#import "DLFYapDatabaseViewAndMapping.h"
#import "DLFDatabaseManager.h"
#import "SyncEngine.h"
#import "Tag.h"
#import "SortTableViewController.h"
#import "StickyHeaderFlowLayout.h"
#import "UIColor+Additionals.h"
#import "PureLayout.h"
#import "MBProgressHUD.h"

@interface MigratingLabel : UIView

@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) UIView *wrappingView;

@end

@interface FavoritesDataSource : GroupedPhotosDataSource

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *favoritesMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *flattenedFavoritesMapping;

@end

@interface FavoritesViewController () <UICollectionViewDelegateFlowLayout, YapDataSourceDelegate>

@property (nonatomic, assign) BOOL viewJustDidLoad;
@property (nonatomic, assign) NSInteger numberOfPhotosToMigrate;
@property (nonatomic, strong) MigratingLabel *migratingLabel;

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_IPAD) {
        StickyHeaderFlowLayout *stickyLayout = [[StickyHeaderFlowLayout alloc] init];
        [stickyLayout setHideHeader:YES];
        [self.collectionView setCollectionViewLayout:stickyLayout animated:NO];
    } else {
        [((StickyHeaderFlowLayout *)self.collectionView.collectionViewLayout) setHideHeader:YES];
    }
    
    self.viewJustDidLoad = YES;
    
    Tag *favoriteTag = [Tag modelWithDictionary:@{NSStringFromSelector(@selector(tagId)):favoritesTagName} error:nil];
    self.item = favoriteTag;
    
    [((YapDataSource *)self.dataSource) setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.numberOfPhotosToMigrate == 0) {
        BOOL needToRestoreOffset = NO;
        if (self.collectionView.contentOffset.y == -self.collectionView.contentInset.top) {
            needToRestoreOffset = YES;
        }
        [self restoreContentInset];
        if (needToRestoreOffset) {
            self.collectionView.contentOffset = CGPointMake(0,  -self.collectionView.contentInset.top);
        }
        
        [((YapDataSource *)self.dataSource) setPause:NO];
        [self.refreshControl removeFromSuperview];
        
        if (self.viewJustDidLoad) {
            self.viewJustDidLoad = NO;
            NSInteger numberOfPhotosToMigrate = [[FavoritesManager sharedManager] numberOfPhotosToMigrate];
            if (numberOfPhotosToMigrate > 0) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesManagerMigratePhotosNotification:) name:FavoritesManagerWillMigratePhotosNotification object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesManagerMigratePhotosNotification:) name:FavoritesManagerDidMigratePhotosNotification object:nil];
            }
            __weak typeof (self) selfie = self;
            [[[FavoritesManager sharedManager] migratePreviousFavorites] continueWithBlock:^id(BFTask *task) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [selfie setupRefreshControl];
                    [selfie setRegisterSyncingNotification:YES];
                    [[SyncEngine sharedEngine] startSyncingPhotosInCollection:selfie.item.itemId collectionType:[Tag class] sort:dateUploadedDescSortKey];
                    [[NSNotificationCenter defaultCenter] removeObserver:selfie name:FavoritesManagerWillMigratePhotosNotification object:nil];
                    [[NSNotificationCenter defaultCenter] removeObserver:selfie name:FavoritesManagerDidMigratePhotosNotification object:nil];
                });
                
                return nil;
            }];
        }
    }
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self setIsFetching:NO];
}

- (void)pauseSyncing:(BOOL)pause {
    [self setRegisterSyncingNotification:!pause];
    [((YapDataSource *)self.dataSource) setPause:pause];
    if (self.migratingState == MigratingStateDone) {
        [[SyncEngine sharedEngine] pauseSyncingPhotos:pause collection:favoritesTagName collectionType:[Tag class]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class)dataSourceClass {
    return [FavoritesDataSource class];
}

- (void)showNoItems:(BOOL)show {
    if (!show) {
        [super showEmptyLoading:show];
    } else {
        UIView *view = self.collectionView.backgroundView;
                
        if (!view) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
            [self.collectionView setBackgroundView:view];
            [view setBackgroundColor:[UIColor whiteColor]];
        } else {
            for (UIView *subview in view.subviews) {
                [subview removeFromSuperview];
            }
        }
        
        UILabel *textLabel = (UILabel *)[view viewWithTag:10000];
        if (!textLabel) {
            textLabel = [[UILabel alloc] initForAutoLayout];
            [textLabel setNumberOfLines:0];
            [textLabel setTag:10000];
            [view addSubview:textLabel];
            [textLabel autoCenterInSuperview];
            
            [textLabel setTextColor:[UIColor lightGrayColor]];
            [textLabel setFont:[UIFont systemFontOfSize:12]];
            [textLabel setTextAlignment:NSTextAlignmentCenter];
        }
        
        [textLabel setText:[self noPhotosMessage]];
        [textLabel sizeToFit];
    }
}

- (NSString *)noPhotosMessage {
    return NSLocalizedString(@"Favorited photos will appear here", nil);
}

- (void)setMigratingState:(MigratingState)migratingState {
    if (_migratingState != migratingState) {
        _migratingState = migratingState;
    }
    
    [self didChangeMigratingState];
}

- (void)didChangeMigratingState {
    switch (self.migratingState) {
        case MigratingStateDone:{
            [self setAutomaticallyAdjustsScrollViewInsets:YES];
            [self.collectionView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height, 0, 0, 0)];
            [self.migratingLabel setHidden:YES];
            break;
        }
        case MigratingStateRunning:{
            [self setAutomaticallyAdjustsScrollViewInsets:NO];
            BOOL adjustOffset = self.collectionView.contentOffset.y == -self.collectionView.contentInset.top;
            [self.collectionView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height + 50, 0, 0, 0)];
            if (adjustOffset) [self.collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top) animated:YES];
            
            if (!self.migratingLabel) {
                self.migratingLabel = [[MigratingLabel alloc] initWithFrame:CGRectMake(0, -50, self.collectionView.frame.size.width, 50)];
                [self.collectionView addSubview:self.migratingLabel];
            }
            [self.migratingLabel setHidden:NO];
            break;
        }
        default:
            break;
    }
}

- (void)setIsFetching:(BOOL)isFetching {
    if (isFetching) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:indicator];
        [self.tabBarController.navigationItem setRightBarButtonItem:item];
        [indicator startAnimating];
    } else {
        [self.tabBarController.navigationItem setRightBarButtonItem:nil];
    }
}

#pragma mark - Rotation

- (void)dlf_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super dlf_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.migratingLabel setFrame:CGRectMake(0, -50, size.width, 50)];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 0, 0, 0);
}

#pragma mark - Upload Notification

- (void)uploadNumberChangeNotification:(NSNotification *)notification {
}

#pragma mark - Syncing Notifications {

- (void)willStartSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    NSString *item = userInfo[SyncEngineNotificationIdentifierKey];
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])] && [item isEqualToString:self.item.itemId]) {
        
        [self setIsFetching:YES];
        self.isDoneSyncing = NO;
    }
}

- (void)didFinishSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    NSString *item = userInfo[SyncEngineNotificationIdentifierKey];
    if (![item isKindOfClass:[NSNull class]] && [resource isEqualToString:NSStringFromClass([self resourceClass])] && [item isEqualToString:self.item.itemId]) {
        
        NSNumber *count = userInfo[SyncEngineNotificationCountKey];
        if (count.intValue == 0) {
            
            [self setIsFetching:NO];
            self.isDoneSyncing = YES;
        }
        
        if (self.dataSource.numberOfItems == 0) {
            [self showNoItems:YES];
        }
    }
}

- (void)didFailSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    NSString *item = userInfo[SyncEngineNotificationIdentifierKey];
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])] && [item isEqualToString:self.item.itemId]) {
        [self setIsFetching:NO];
    }
}

#pragma mark - Migrate Notifications

- (void)favoritesManagerMigratePhotosNotification:(NSNotification *)notification {
    NSInteger count = [[notification.userInfo objectForKey:FavoritesManagerMigratedPhotosCountKey] integerValue];
    self.numberOfPhotosToMigrate = count;
    if (count > 0) {
        self.migratingState = MigratingStateRunning;
        [self.migratingLabel.label setText:[NSString stringWithFormat:NSLocalizedString(@"Tagging %d locally favorited photos", nil), (int)count]];
        if (![self.migratingLabel.indicatorView isAnimating]) [self.migratingLabel.indicatorView startAnimating];
    } else self.migratingState = MigratingStateDone;
    
}

@end

#pragma mark -

@implementation FavoritesDataSource

- (void)setupMapping {
    self.favoritesMapping = [[FavoritesManager sharedManager] databaseViewMapping];
    self.flattenedFavoritesMapping = [[FavoritesManager sharedManager] flattenedDatabaseViewMapping];
}

- (void)setDefaultMapping {
    self.selectedViewMapping = self.favoritesMapping;
}

- (DLFYapDatabaseViewAndMapping *)selectedFlattenedViewMapping {
    return self.flattenedFavoritesMapping;
}

@end

#pragma mark -

@implementation MigratingLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIView *view = [[UIView alloc] initForAutoLayout];
        [view setBackgroundColor:[UIColor clearColor]];
        
        UILabel *label = [[UILabel alloc] initForAutoLayout];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:[UIColor lightGrayTextColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [view addSubview:label];
        self.label = label;
        [self.label autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:view];
        [self.label autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:view];
        [self.label autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:view];
        [self.label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [view addSubview:indicator];
        self.indicatorView = indicator;
        [self.indicatorView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.label withOffset:10];
        [self.indicatorView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:view];
        [self.indicatorView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.label];
        
        [self addSubview:view];
        [view autoCenterInSuperview];
        
        self.wrappingView = view;
    }
    return self;
}

@end
