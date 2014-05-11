//
//  PhotosViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosViewController.h"

#import "Album.h"
#import "Photo.h"
#import "Tag.h"

#import "LocationManager.h"
#import "ConnectionManager.h"

#import "PhotosSectionHeaderView.h"
#import "PhotoCell.h"

#import "PhotosHorizontalScrollingViewController.h"
#import "SettingsTableViewController.h"

#import "CollectionViewSelectCellGestureRecognizer.h"

#import "UIView+Additionals.h"
#import "NSString+Additionals.h"
#import "UIViewController+Additionals.h"

#import <JASidePanelController.h>
#import "UIViewController+DelightfulViewControllers.h"

#import "AppDelegate.h"

#import "DelightfulLayout.h"

#import "PhotosDataSource.h"

#import "Photo.h"

@interface PhotosViewController () <UICollectionViewDelegateFlowLayout, PhotosHorizontalScrollingViewControllerDelegate>

@property (nonatomic, strong) PhotoBoxCell *selectedCell;
@property (nonatomic, assign) CGRect selectedItemRect;
@property (nonatomic, strong) CollectionViewSelectCellGestureRecognizer *selectGesture;
@property (nonatomic, assign) BOOL observing;
@end

@implementation PhotosViewController

@synthesize item = _item;

@synthesize numberOfColumns = _numberOfColumns;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.numberOfColumns = 3;
    [self setPhotosCount:0 max:0];
    
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    
    [self.collectionView.viewForBaselineLayout.layer setSpeed:0.4f];
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    [self.collectionView registerClass:[PhotosSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[self sectionHeaderIdentifier]];
    
    //self.selectGesture = [[CollectionViewSelectCellGestureRecognizer alloc] initWithCollectionView:self.collectionView];
    
    self.resourceType = PhotoResource;
    self.relationshipKeyPathWithItem = @"albums";
    
    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [settingButton setImage:[[UIImage imageNamed:@"setting.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    [self.navigationItem setRightBarButtonItem:settingBarButtonItem];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.observing) {
        self.observing = YES;
        JASidePanelController *panel = [UIViewController panelViewController];
        if (panel) {
            [panel addObserver:self forKeyPath:@"state" options:0 context:nil];
        }
    }
    
    if (![((AppDelegate *)[[UIApplication sharedApplication] delegate]) showUpdateInfoViewIfNeeded]) {
        [self showPinchGestureTipIfNeeded];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override

- (CollectionViewHeaderCellConfigureBlock)headerCellConfigureBlock {
    __weak typeof (self) selfie = self;
    void (^configureCell)(PhotosSectionHeaderView*, id,NSIndexPath*) = ^(PhotosSectionHeaderView* cell, id item, NSIndexPath *indexPath) {
        [cell setHidden:(selfie.numberOfColumns==1)?YES:NO];
        [cell setTitleLabelText:[item localizedDate]];
        CLLocation *location = [selfie locationSampleForSection:indexPath.section];
        if (location) {
            [[LocationManager sharedManager] nameForLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                if (!error && placemarks && placemarks.count > 0) {
                    [cell setLocation:placemarks[0]];
                } else {
                    [cell setLocation:nil];
                }
            }];
        } else {
            [cell setLocation:nil];
        }
    };
    return configureCell;
}

- (CollectionViewCellConfigureBlock)cellConfigureBlock {
    void (^configureCell)(PhotoCell*, id) = ^(PhotoCell* cell, id item) {
        [cell setItem:item];
        [cell setNumberOfColumns:self.numberOfColumns];
    };
    return configureCell;
}

- (NSString *)cellIdentifier {
    return @"photoCell";
}

- (NSString *)groupKey {
    return NSStringFromSelector(@selector(dateTakenString));
}

- (NSArray *)sortDescriptors {
    return nil;
}

- (NSString *)sectionHeaderIdentifier {
    return @"photoSection";
}

- (Class)resourceClass {
    return [Photo class];
}

- (NSString *)resourceId {
    return self.item.itemId;
}

- (Class)dataSourceClass {
    return [PhotosDataSource class];
}

- (void)refresh {
    if ([self itemIsDownloadHistoryOrFavorites]) {
        Album *album = (Album *)self.item;
        [self.dataSource removeAllItems];
        [self.dataSource addItems:album.photos];
        [self.refreshControl endRefreshing];
        return;
    }
    [super refresh];
}

- (BOOL)itemIsDownloadHistoryOrFavorites {
    if ([self.item isKindOfClass:[Album class]]) {
        Album *album = (Album *)self.item;
        if ([album.albumId isEqualToString:PBX_downloadHistoryIdentifier] ||[album.albumId isEqualToString:PBX_favoritesAlbumIdentifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)fetchMore {
    if ([self itemIsDownloadHistoryOrFavorites]) {
        return;
    } else {
        [super fetchMore];
    }
}

#pragma mark - Do something

- (void)settingButtonTapped:(id)sender {
    SettingsTableViewController *settings = [[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:settings];
    [self presentViewController:navCon animated:YES completion:nil];
}

- (void)backNavigationTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupBackNavigationItemTitle {
    if (self.item) {
        if ([self.item isKindOfClass:[Album class]]) {
            [self setBackButtonNavigationItemTitle:((Album *)self.item).name];
        } else if ([self.item isKindOfClass:[Tag class]]) {
            [self setBackButtonNavigationItemTitle:((Tag *)self.item).tagId];
        }
    } else {
        [self setBackButtonNavigationItemTitle:nil];
    }
}

- (void)setBackButtonNavigationItemTitle:(NSString *)title {
    if (!title) {
        title = NSLocalizedString(@"Gallery", nil);
    }
    if (!self.navigationItem.backBarButtonItem) {
        [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backNavigationTapped:)]];
    }
    [self.navigationItem.backBarButtonItem setTitle:title];
}

- (void)showLoadingView:(BOOL)show {
    DelightfulLayout *layout = (DelightfulLayout *)self.collectionView.collectionViewLayout;
    [layout updateLastIndexPath];
    [layout setShowLoadingView:show];
    
    CGFloat centerY = LOADING_VIEW_HEIGHT/2;
    if (layout.lastIndexPath && layout.lastIndexPath.section != NSIntegerMin && layout.lastIndexPath.item != NSIntegerMin) {
        centerY += CGRectGetMaxY([layout layoutAttributesForItemAtIndexPath:layout.lastIndexPath].frame);
    }
    
    [self showLoadingView:show atCenterY:centerY];
    [layout invalidateLayout];
}

- (void)setNumberOfColumns:(int)numberOfColumns {
    if (_numberOfColumns != numberOfColumns) {
        _numberOfColumns = numberOfColumns;
                
        DelightfulLayout *layout = (DelightfulLayout *)self.collectionView.collectionViewLayout;
        [layout setNumberOfColumns:_numberOfColumns];
    }
}

- (void)didFetchItems {
    NSInteger count = [self.dataSource numberOfItems];
    [self setPhotosCount:count max:self.totalItems];
}

- (void)didChangeNumberOfColumns {
    for (PhotoCell *cell in self.collectionView.visibleCells) {
        [cell setNumberOfColumns:self.numberOfColumns];
    }
}

- (void)showPinchGestureTipIfNeeded {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![[ConnectionManager sharedManager] isShowingLoginPage]) {
            if (!self.presentedViewController) {
                BOOL hasShownTip = [[NSUserDefaults standardUserDefaults] boolForKey:DLF_DID_SHOW_PINCH_GESTURE_TIP];
                if (!hasShownTip) {
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DLF_DID_SHOW_PINCH_GESTURE_TIP];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hint", nil) message:NSLocalizedString(@"Try to pinch-in and out on this screen :)", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
    });
    
}

#pragma mark - Setters

- (void)setPhotosCount:(int)count max:(int)max{
    if ([self itemIsDownloadHistoryOrFavorites]) {
        Album *album = (Album *)self.item;
        self.title = album.name;
        return;
    }
    NSString *title = NSLocalizedString(@"Photos", nil);
    if ([self.item isKindOfClass:[Album class]]) {
        Album *album = (Album *)self.item;
        if (album) {
            title = album.name;
        }
    } else if ([self.item isKindOfClass:[Tag class]]) {
        Tag *tag = (Tag *)self.item;
        if (tag) {
            title = [NSString stringWithFormat:@"#%@", tag.tagId];
        }
    }
    if (count == 0) {
        self.title = title;
    } else {
        if (count != max) [self setTitle:title subtitle:[NSString stringWithFormat:NSLocalizedString(@"%1$d of %2$d", nil), count, max]];
        else [self setTitle:title subtitle:[NSString stringWithFormat:@"%d photos", count]];
    }
}

- (void)setSelectedItemRectAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    self.selectedItemRect = attributes.frame;
}

#pragma mark - Collection view flow layout delegate

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.numberOfColumns == 1) {
        return UIEdgeInsetsMake(5, 0, 0, 0);
    }
    return UIEdgeInsetsZero;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotosHorizontalScrollingViewController *destination = [[PhotosHorizontalScrollingViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    
    PhotoBoxCell *cell = (PhotoBoxCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [destination setItem:self.item];
    [destination.dataSource addItems:self.dataSource.flattenedItems];
    [destination setFirstShownPhoto:cell.item];
    [destination setFirstShownPhotoIndex:[self.dataSource positionOfItem:cell.item]];
    [destination setDelegate:self];
    [destination setRelationshipKeyPathWithItem:self.relationshipKeyPathWithItem];
    [destination setResourceType:self.resourceType];
    if ([self itemIsDownloadHistoryOrFavorites]) {
        [destination setHideDownloadButton:YES];
    }
    
    self.selectedCell = cell;
    [self setSelectedItemRectAtIndexPath:indexPath];
    
    [self setupBackNavigationItemTitle];
    
    [self.navigationController pushViewController:destination animated:YES];
}

#pragma mark - CustomAnimationTransitionFromViewControllerDelegate

- (UIImage *)imageToAnimate {
    return self.selectedCell.cellImageView.image;
}

- (CGRect)startRectInContainerView:(UIView *)containerView {
    return [self.selectedCell convertFrameRectToView:containerView];
}

- (CGRect)endRectInContainerView:(UIView *)containerView {
    CGRect originalPosition = CGRectOffset(self.selectedItemRect, 0, self.collectionView.contentInset.top);
    CGFloat adjustment = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
    return CGRectOffset(originalPosition, 0, -adjustment);
}

- (UIView *)viewToAnimate {
    return nil;
}

#pragma mark - PhotosHorizontalScrollingViewControllerDelegate

- (void)photosHorizontalScrollingViewController:(PhotosHorizontalScrollingViewController *)viewController didChangePage:(NSInteger)page item:(Photo *)item {
    PBX_LOG(@"Change page %d of %d", page, [self.dataSource numberOfItems]);
    NSIndexPath *indexPath = [self.dataSource indexPathOfItem:item];
    if (indexPath) {
        PBX_LOG(@"Index path target section %d row %d", indexPath.section, indexPath.item);
        PBX_LOG(@"Current number of sections %d. Number of items in section = %d", [self.collectionView numberOfSections], [self.collectionView numberOfItemsInSection:indexPath.section]);
        if (indexPath.section < [self.collectionView numberOfSections]) {
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            
            [self setSelectedItemRectAtIndexPath:indexPath];
        }
    }
    
}

- (UIView *)snapshotView {
    return [self.view snapshotViewAfterScreenUpdates:YES];
}

- (CGRect)selectedItemRectInSnapshot {
    return [self endRectInContainerView:nil];
}

- (void)photosHorizontalWillClose {
    [self setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Location

- (CLLocation *)locationSampleForSection:(NSInteger)sectionIndex {
    CLLocation *location;
    NSArray *photos = [self.dataSource items][sectionIndex];
    for (Photo *photo in photos) {
        NSNumber *latitude = [photo valueForKey:@"latitude"];
        NSNumber *longitude = [photo valueForKey:@"longitude"];
        if (latitude && ![latitude isKindOfClass:[NSNull class]] && longitude && ![longitude isKindOfClass:[NSNull class]]) {
            location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            
            break;
        }
    }
    return location;
}


@end
