//
//  FavoritesViewController.m
//  Delightful
//
//  Created by  on 11/16/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "FavoritesViewController.h"
#import "GroupedPhotosDataSource.h"
#import "FavoritesManager.h"
#import "DLFYapDatabaseViewAndMapping.h"
#import "DLFDatabaseManager.h"
#import "SyncEngine.h"
#import "Tag.h"
#import "SortTableViewController.h"
#import <UIView+AutoLayout.h>
#import <MBProgressHUD.h>

@interface FavoritesDataSource : GroupedPhotosDataSource

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *favoritesMapping;
@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *flattenedFavoritesMapping;

@end

@interface FavoritesViewController () <UICollectionViewDelegateFlowLayout, YapDataSourceDelegate>

@property (nonatomic, assign) BOOL viewJustDidLoad;

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewJustDidLoad = YES;
    [self migratePreviousFavorites];
    
    [((YapDataSource *)self.dataSource) setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    BOOL needToRestoreOffset = NO;
    if (self.collectionView.contentOffset.y == -self.collectionView.contentInset.top) {
        needToRestoreOffset = YES;
    }
    [self restoreContentInset];
    if (needToRestoreOffset) {
        self.collectionView.contentOffset = CGPointMake(0,  -self.collectionView.contentInset.top);
    }
    
    [((YapDataSource *)self.dataSource) setPause:NO];
    
    if (self.viewJustDidLoad) {
        self.viewJustDidLoad = NO;
    } else {
        [self pauseSync:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self pauseSync:YES];
}

- (void)pauseSync:(BOOL)pauseSync {
    [[SyncEngine sharedEngine] pauseSyncingPhotos:pauseSync collection:favoritesTagName collectionType:[Tag class]];
}

- (void)migratePreviousFavorites {
    __block NSMutableArray *localFavoritesFromPreviousVersion = [NSMutableArray array];
    [[[DLFDatabaseManager manager] readConnection] asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [transaction enumerateKeysInCollection:favoritedPhotosCollectionName usingBlock:^(NSString *key, BOOL *stop) {
            [localFavoritesFromPreviousVersion addObject:key];
        }];
    } completionBlock:^{
        BFTask *task = [BFTask taskWithResult:nil];
        for (NSString *photoId in localFavoritesFromPreviousVersion) {
            task = [task continueWithBlock:^id(BFTask *t) {
                return [[[FavoritesManager sharedManager] addPhotoWithId:photoId] continueWithBlock:^id(BFTask *t2) {
                    Photo *object = t2.result;
                    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
                    [[[DLFDatabaseManager manager] writeConnection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                        [transaction removeObjectForKey:photoId inCollection:favoritedPhotosCollectionName];
                    } completionBlock:^{
                        [taskCompletionSource setResult:object];
                    }];
                    return taskCompletionSource.task;
                }];
            }];
        }
        
        [task continueWithBlock:^id(BFTask *task) {
            [[SyncEngine sharedEngine] startSyncingPhotosInCollection:favoritesTagName collectionType:[Tag class] sort:dateUploadedDescSortKey];
            return nil;
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class)dataSourceClass {
    return [FavoritesDataSource class];
}

- (void)showEmptyLoading:(BOOL)show {
    if (!show) {
        [super showEmptyLoading:show];
    } else {
        UIView *view = self.collectionView.backgroundView;
        
        //[self.collectionView setAlwaysBounceVertical:NO];
        
        if (!view) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
            [self.collectionView setBackgroundView:view];
            [view setBackgroundColor:[UIColor whiteColor]];
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

- (void)setupRefreshControl {
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


@end

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
