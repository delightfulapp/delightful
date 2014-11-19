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
#import "FooterLoadingReusableView.h"
#import "PhotoCell.h"

#import "PhotosHorizontalScrollingYapBackedViewController.h"
#import "SettingsTableViewController.h"

#import "CollectionViewSelectCellGestureRecognizer.h"

#import "UIView+Additionals.h"
#import "NSString+Additionals.h"
#import "UIViewController+Additionals.h"

#import "AppDelegate.h"

#import "DelightfulLayout.h"

#import "GroupedPhotosDataSource.h"

#import "Photo.h"

#import "Album.h"

#import "Tag.h"

#import "StickyHeaderFlowLayout.h"

#import "UIImageView+Additionals.h"

#import "NoPhotosView.h"

#import "HeaderImageView.h"

#import "FallingTransitioningDelegate.h"

#import "PhotosPickerViewController.h"

#import "DelightfulCache.h"

#import "TagsAlbumsPickerViewController.h"

#import "DLFAsset.h"

#import "ShowFullScreenTransitioningDelegate.h"

#import "NSAttributedString+DelighftulFonts.h"

#import "SyncEngine.h"

#import "SortTableViewController.h"

@interface PhotosViewController () <UICollectionViewDelegateFlowLayout, PhotosHorizontalScrollingViewControllerDelegate, UINavigationControllerDelegate, TagsAlbumsPickerViewControllerDelegate, SortingDelegate>

@property (nonatomic, strong) CollectionViewSelectCellGestureRecognizer *selectGesture;
@property (nonatomic, assign) BOOL observing;
@property (nonatomic, weak) HeaderImageView *headerImageView;
@property (nonatomic, weak) NoPhotosView *noPhotosView;
@property (nonatomic, strong) NSMutableArray *uploadingPhotos;

@property (nonatomic, strong) FallingTransitioningDelegate *fallingTransitioningDelegate;
@property (nonatomic, strong) ShowFullScreenTransitioningDelegate *transitionDelegate;
@property (nonatomic, assign) BOOL viewJustDidLoad;

@end

@implementation PhotosViewController

@synthesize numberOfColumns = _numberOfColumns;

- (void)viewDidLoad
{
    self.resourceType = PhotoResource;
    self.relationshipKeyPathWithItem = @"albums";
    
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.numberOfColumns = 3;
    
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    [self.collectionView registerClass:[PhotosSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[self sectionHeaderIdentifier]];
    [self.collectionView registerClass:[FooterLoadingReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:[self footerIdentifier]];
    
    self.title = NSLocalizedString(@"Photos", nil);
    
    self.currentSort = @"dateUploaded,desc";
    
    self.viewJustDidLoad = YES;
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
    
    if (self.viewJustDidLoad) {
        self.viewJustDidLoad = NO;
        [[SyncEngine sharedEngine] startSyncingPhotosInCollection:nil collectionType:nil sort:dateUploadedDescSortKey];
    } else {
        [[SyncEngine sharedEngine] pauseSyncingPhotos:NO collection:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"view will disappear");
    [self setRegisterSyncingNotification:NO];
    [((YapDataSource *)self.dataSource) setPause:YES];
    [[SyncEngine sharedEngine] pauseSyncingPhotos:YES collection:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    CLS_LOG(@"did receive memory warning");
}

#pragma mark - Buttons

- (void)didTapSortButton:(id)sender {
    SortTableViewController *sort = [[SortTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [sort setSortingDelegate:self];
    [sort setSelectedSort:self.currentSort];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sort];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - SortingDelegate

- (void)sortTableViewController:(id)sortTableViewController didSelectSort:(NSString *)sort {
    if (![self.currentSort isEqualToString:sort]) {
        [((GroupedPhotosDataSource *)self.dataSource) setSelectedViewMapping:nil];
        self.currentSort = sort;
        PhotosSortKey selectedSortKey;
        NSArray *sortArray = [sort componentsSeparatedByString:@","];
        if ([[sortArray objectAtIndex:0] isEqualToString:NSStringFromSelector(@selector(dateTaken))]) {
            selectedSortKey = PhotosSortKeyDateTaken;
        } else {
            selectedSortKey = PhotosSortKeyDateUploaded;
        }
        BOOL ascending = YES;
        if ([[[sortArray objectAtIndex:1] lowercaseString] isEqualToString:@"desc"]) {
            ascending = NO;
        }
        
        
        if (self.item) {
            [[SyncEngine sharedEngine] refreshPhotosInCollection:self.item.itemId collectionType:self.item.class sort:self.currentSort];
        } else {
            [[SyncEngine sharedEngine] setPhotosSyncSort:sort];
            [[SyncEngine sharedEngine] refreshResource:NSStringFromClass([Photo class])];
        }
        
        [sortTableViewController dismissViewControllerAnimated:YES completion:^{
            [((GroupedPhotosDataSource *)self.dataSource) sortBy:selectedSortKey ascending:ascending completion:^{
            }];
        }];
    } else {
        [sortTableViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.headerImageView) {
        CGFloat headerHeight = self.headerImageView.intrinsicContentSize.height;
        CGFloat maxOffset = headerHeight + 100;
        CGFloat minOffset = -headerHeight;
        if (scrollView.contentOffset.y <= minOffset) {
            CGFloat scale = 1 +(float)(fabsf(scrollView.contentOffset.y) + minOffset)/(float)(fabsf(maxOffset + minOffset));
            
            self.headerImageView.imageView.transform = CGAffineTransformMakeScale(scale, scale);
        }
        CGFloat translate = scrollView.contentOffset.y - (-headerHeight);

        self.headerImageView.transform = CGAffineTransformMakeTranslation(0, MIN(0, -translate));
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CLS_LOG(@"will begin dragging");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        CLS_LOG(@"end dragging");
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    CLS_LOG(@"did end scrolling animation");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CLS_LOG(@"did end decelerating");
}

#pragma mark - Override

- (CollectionViewHeaderCellConfigureBlock)headerCellConfigureBlock {
    __weak typeof (self) selfie = self;
    void (^configureCell)(PhotosSectionHeaderView*, id,NSIndexPath*) = ^(PhotosSectionHeaderView* cell, id item, NSIndexPath *indexPath) {
        [cell setHidden:(selfie.numberOfColumns==1)?YES:NO];
        if (selfie.numberOfColumns > 1) {
            Photo *firstObject = [selfie.dataSource itemAtIndexPath:indexPath];
            if (firstObject.asset) {
                [cell setTitleLabelText:NSLocalizedString(@"Uploading ...", nil)];
                [cell setLocationString:nil];
            } else {
                [cell setTitleLabelText:[item localizedDate]?:@""];
                CLLocation *location = [selfie locationSampleForSection:indexPath.section];
                if (location) {
                    [[LocationManager sharedManager] nameForLocation:location completionHandler:^(NSString *placemarks, NSError *error) {
                        if (placemarks) {
                            [cell setLocationString:placemarks];
                        } else {
                            [cell setLocationString:nil];
                        }
                    }];
                } else {
                    [cell setLocationString:nil];
                }
            }
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

- (NSString *)footerIdentifier {
    return @"loadingFooter";
}

- (Class)resourceClass {
    return [Photo class];
}

- (Class)dataSourceClass {
    return [GroupedPhotosDataSource class];
}

- (void)restoreContentInset {
    PBX_LOG(@"");
    
    if (self.headerImageView) {
        CGFloat headerHeight = self.headerImageView.intrinsicContentSize.height;
        self.collectionView.contentInset = ({
            UIEdgeInsets inset = self.collectionView.contentInset;
            inset.top = headerHeight;
            inset;
        });
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    } else {
        [super restoreContentInsetForSize:self.view.frame.size];
        self.collectionView.contentInset = ({
            UIEdgeInsets inset = self.collectionView.contentInset;
            inset;
        });
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    }
}

#pragma mark - Do something

- (void)backNavigationTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)setNumberOfColumns:(int)numberOfColumns {
    if (_numberOfColumns != numberOfColumns) {
        _numberOfColumns = numberOfColumns;
                
        DelightfulLayout *layout = (DelightfulLayout *)self.collectionView.collectionViewLayout;
        [layout setNumberOfColumns:_numberOfColumns];
    }
}

- (void)didChangeNumberOfColumns {
    for (PhotoCell *cell in self.collectionView.visibleCells) {
        [cell setNumberOfColumns:self.numberOfColumns];
    }
}

- (void)showPinchGestureTipIfNeeded {
    return;
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

#pragma mark - Collection view flow layout delegate

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.numberOfColumns == 1) {
        return UIEdgeInsetsMake(5, 0, 0, 0);
    }
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == [((GroupedPhotosDataSource *)self.dataSource) numberOfSectionsInCollectionView:collectionView]-1) {
        if (self.isFetching) {
            return CGSizeMake(CGRectGetWidth(collectionView.frame), 54);
        }
    }
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 0);
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self viewWillDisappear:YES];
    
    PhotoBoxCell *cell = (PhotoBoxCell *)[collectionView cellForItemAtIndexPath:indexPath];
    Photo *photo = (Photo *)cell.item;
    if (photo.asset) {
        return;
    }
    self.selectedCell = cell;
    
    [self openPhoto:cell.item];
}

- (void)openPhoto:(Photo *)photo{
    PhotosHorizontalScrollingYapBackedViewController *destination = [PhotosHorizontalScrollingYapBackedViewController defaultControllerWithViewMapping:[((GroupedPhotosDataSource *)self.dataSource) selectedFlattenedViewMapping]];
    [destination setFirstShownPhoto:photo];
    [destination setDelegate:self];
    if (!self.transitionDelegate) {
        self.transitionDelegate = [[ShowFullScreenTransitioningDelegate alloc] init];
    }
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:destination];
    [navCon setTransitioningDelegate:self.transitionDelegate];
    [navCon setModalPresentationStyle:UIModalPresentationCustom];
    
    {
        UIButton *label = [[UIButton alloc] init];
        NSMutableAttributedString *leftArrow = [[NSAttributedString symbol:dlf_icon_arrow_left3 size:25] mutableCopy];
        //[leftArrow addAttribute:NSBaselineOffsetAttributeName value:@(-4) range:NSMakeRange(0, leftArrow.string.length)];
        [leftArrow addAttribute:NSForegroundColorAttributeName value:self.view.tintColor range:NSMakeRange(0, leftArrow.string.length)];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:leftArrow];
        [label setAttributedTitle:attr forState:UIControlStateNormal];
        
        NSMutableAttributedString *selectedAttr = [[NSMutableAttributedString alloc] initWithAttributedString:attr];
        [selectedAttr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, selectedAttr.string.length)];
        [label setAttributedTitle:selectedAttr forState:UIControlStateHighlighted];
        
        [label sizeToFit];
        [label addTarget:self action:@selector(didTapHorizontalBackButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:label];
        UIBarButtonItem *leftSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [leftSpaceItem setWidth:-10];
        
        [destination.navigationItem setLeftBarButtonItems:@[leftSpaceItem, leftItem]];
    }
    
    [self presentViewController:navCon animated:YES completion:nil];
}

- (void)didTapHorizontalBackButton:(id)sender {
    [self shouldClosePhotosHorizontalViewController:nil];
}

#pragma mark - CustomAnimationTransitionFromViewControllerDelegate

- (UIImage *)imageToAnimate {
    if (self.selectedCell) {
        return ((PhotoBoxCell *)self.selectedCell).cellImageView.image;
    }
    if (self.headerImageView) {
        return self.headerImageView.imageView.image;
    }
    return nil;
}

- (CGRect)startRectInContainerView:(UIView *)containerView {
    if (self.selectedCell) {
        return [self.selectedCell convertFrameRectToView:containerView];
    }
    return [self.headerImageView.imageView convertFrameRectToView:containerView];
}

- (CGRect)endRectInContainerView:(UIView *)containerView {
    if (self.selectedCell) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:self.selectedCell];
        UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
        CGRect originalPosition = CGRectOffset(attributes.frame, 0, self.collectionView.contentInset.top);
        CGFloat adjustment = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
        return CGRectOffset(originalPosition, 0, -adjustment);
    } else {
        return self.headerImageView.frame;
    }
    return CGRectZero;
    
}

- (UIView *)destinationViewOnDismiss {
    if (self.selectedCell) {
        return self.selectedCell;
    }
    return self.headerImageView;
}

- (UIView *)viewToAnimate {
    return nil;
}

#pragma mark - PhotosHorizontalScrollingViewControllerDelegate

- (void)photosHorizontalScrollingViewController:(PhotosHorizontalScrollingViewController *)viewController didChangePage:(NSInteger)page item:(Photo *)item {
    NSIndexPath *indexPath = [self.dataSource indexPathOfItem:item];
    if (indexPath) {
        if (indexPath.section < [self.collectionView numberOfSections]) {
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            self.selectedCell = (PhotoBoxCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        }
    }
    
}

- (void)shouldClosePhotosHorizontalViewController:(PhotosHorizontalScrollingViewController *)controller {
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        if (cell != self.selectedCell) {
            [cell setAlpha:1];
        }
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self dismissViewControllerAnimated:YES completion:^{
        for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
            [cell setAlpha:1];
        }
        self.selectedCell = nil;
        
        [self viewDidAppear:YES];
    }];
}

- (void)willDismissViewController:(PhotosHorizontalScrollingViewController *)controller {
    [self.selectedCell setAlpha:0];
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        if (cell != self.selectedCell) {
            [cell setAlpha:1];
        }
    }
}

- (void)cancelDismissViewController:(PhotosHorizontalScrollingViewController *)controller {
    [self.selectedCell setAlpha:1];
}

#pragma mark - Location

- (CLLocation *)locationSampleForSection:(NSInteger)sectionIndex {
    __block CLLocation *location;
    
    [self.dataSource enumerateKeysAndObjectsInSection:sectionIndex usingBlock:^(NSString *collection, NSString *key, Photo *photo, NSUInteger index, BOOL *stop) {
        NSNumber *latitude = [photo valueForKey:@"latitude"];
        NSNumber *longitude = [photo valueForKey:@"longitude"];
        if (latitude && ![latitude isKindOfClass:[NSNull class]] && longitude && ![longitude isKindOfClass:[NSNull class]]) {
            location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            
            *stop = YES;
        }
    }];
    
    return location;
}

@end
