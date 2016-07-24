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
#import "GroupedPhotosDataSource.h"
#import "Photo.h"
#import "Album.h"
#import "Tag.h"
#import "StickyHeaderFlowLayout.h"
#import "UIImageView+Additionals.h"
#import "NoPhotosView.h"
#import "HeaderImageView.h"
#import "DelightfulCache.h"
#import "TagsAlbumsPickerViewController.h"
#import "DLFAsset.h"
#import "ShowFullScreenTransitioningDelegate.h"
#import "NSAttributedString+DelighftulFonts.h"
#import "SyncEngine.h"
#import "SortTableViewController.h"
#import "UploadViewController.h"
#import "DLFImageUploader.h"
#import "SortingConstants.h"
#import "DLFDatabaseManager.h"
#import "PHPhotoLibrary+Additionals.h"
#import "NHBalancedFlowLayout.h"
#import "CollectionViewChangeColumnsNumberGestureRecognizer.h"
#import "PureLayout.h"
#import "DLFPhotoCell.h"
#import "DLFPhotosPickerViewController.h"
#import "DLFDetailViewController.h"
#import "CLPlacemark+Additionals.h"

#define UPLOADED_MARK_TAG 123456910

@interface PhotosViewController () <UICollectionViewDelegateFlowLayout, PhotosHorizontalScrollingViewControllerDelegate, UINavigationControllerDelegate, TagsAlbumsPickerViewControllerDelegate, SortingDelegate, DLFPhotosPickerViewControllerDelegate, UploadViewControllerDelegate, NHBalancedFlowLayoutDelegate, CollectionViewChangeColumnsNumberGestureRecognizerDelegate>

@property (nonatomic, strong) CollectionViewSelectCellGestureRecognizer *selectGesture;
@property (nonatomic, assign) BOOL observing;
@property (nonatomic, weak) HeaderImageView *headerImageView;
@property (nonatomic, weak) NoPhotosView *noPhotosView;
@property (nonatomic, strong) NSMutableArray *uploadingPhotos;
@property (nonatomic, strong) ShowFullScreenTransitioningDelegate *transitionDelegate;
@property (nonatomic, strong) UploadViewController *uploadViewController;
@property (nonatomic, assign) BOOL doneUploadingNeedRefresh;
@property (nonatomic, assign) BOOL _showRightBarButtonItem;
@property (nonatomic, strong) CollectionViewChangeColumnsNumberGestureRecognizer *pinchGestureRecognizer;

@end

@implementation PhotosViewController

- (void)viewDidLoad
{
    self.resourceType = PhotoResource;
    
    if (IS_IPAD) {
        NHBalancedFlowLayout *balancedLayout = [[NHBalancedFlowLayout alloc] init];
        [balancedLayout setPreferredRowSize:self.view.frame.size.height/5];
        [self.collectionView setCollectionViewLayout:balancedLayout animated:NO];
    }
    
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    [self.collectionView registerClass:[PhotosSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[self sectionHeaderIdentifier]];
    [self.collectionView registerClass:[FooterLoadingReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:[self footerIdentifier]];
    
    self.title = NSLocalizedString(@"Photos", nil);
    
    if (self.navigationController.viewControllers.count == 1) {
        UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"upload"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(didTapUploadButton:)];
        [self.navigationItem setLeftBarButtonItem:uploadButton];
    }
    
    self.viewJustDidLoad = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadNumberChangeNotification:) name:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil];
    
    [self configurePinchGesture];
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
        self.currentSort = dateUploadedDescSortKey;
        NSString *sortDefaultsKey = [NSString stringWithFormat:@"%@-%@", DLF_LAST_SELECTED_PHOTOS_SORT, self.item.itemId?:@""];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:sortDefaultsKey]) {
            self.currentSort = [[NSUserDefaults standardUserDefaults] objectForKey:sortDefaultsKey];
        }
        [self selectSort:self.currentSort sortTableViewController:nil];
        [[SyncEngine sharedEngine] startSyncingPhotosInCollection:nil collectionType:nil sort:self.currentSort];
    } else {
        if ([self doneUploadingNeedRefresh]) {
            self.doneUploadingNeedRefresh = NO;
            [self setRegisterSyncingNotification:YES];
            [((YapDataSource *)self.dataSource) setPause:NO];
            [self refresh];
        } else {
            [self pauseSyncing:NO];
        }
    }
    
    if ([self.collectionView.collectionViewLayout isKindOfClass:[NHBalancedFlowLayout class]]) {
        [(NHBalancedFlowLayout *)self.collectionView.collectionViewLayout setForceInvalidate:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"view will disappear");
    [self pauseSyncing:YES];
    if ([self.collectionView.collectionViewLayout isKindOfClass:[NHBalancedFlowLayout class]]) {
        [(NHBalancedFlowLayout *)self.collectionView.collectionViewLayout setForceInvalidate:YES];
    }
}

- (void)pauseSyncing:(BOOL)pause {
    [self setRegisterSyncingNotification:!pause];
    [((YapDataSource *)self.dataSource) setPause:pause];
    [[SyncEngine sharedEngine] pauseSyncingPhotos:pause collection:nil collectionType:self.item.class];
}

- (void)configurePinchGesture {
    if ([self.collectionView.collectionViewLayout isKindOfClass:[StickyHeaderFlowLayout class]]) {
        if (!self.pinchGestureRecognizer) {
            self.pinchGestureRecognizer = [[CollectionViewChangeColumnsNumberGestureRecognizer alloc] initWithCollectionView:self.collectionView numberOfColumnsKey:NSStringFromSelector(@selector(numberOfColumns))];
            [self.pinchGestureRecognizer setDelegate:self];
        } else {
            [self.pinchGestureRecognizer setEnableGesture:YES];
        }
    } else {
        if (self.pinchGestureRecognizer) {
            [self.pinchGestureRecognizer setEnableGesture:NO];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    CLS_LOG(@"did receive memory warning");
}

#pragma mark - Buttons


- (void)showRightBarButtonItem:(BOOL)show {
    if (__showRightBarButtonItem != show) {
        __showRightBarButtonItem = show;
        if (show) {
            if (IS_IPAD) {
                UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapSortButton:)];
                UIImage *layoutButtonImage;
                if ([self.collectionView.collectionViewLayout isKindOfClass:[StickyHeaderFlowLayout class]]) {
                    layoutButtonImage = [UIImage imageNamed:@"balance-layout"];
                } else if ([self.collectionView.collectionViewLayout isKindOfClass:[NHBalancedFlowLayout class]]) {
                    layoutButtonImage = [UIImage imageNamed:@"normal-layout"];
                }
                UIBarButtonItem *layoutItem = [[UIBarButtonItem alloc] initWithImage:layoutButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(didTapChangeLayoutButton:)];
                [self.navigationItem setRightBarButtonItems:@[leftItem, layoutItem]];
            } else {
                if (!self.navigationItem.rightBarButtonItem) {
                    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapSortButton:)];
                    [self.navigationItem setRightBarButtonItem:leftItem];
                }
            }
        } else {
            [self.navigationItem setRightBarButtonItems:nil];
        }
    }
}

- (void)didTapChangeLayoutButton:(UIBarButtonItem *)sender {
    [sender setEnabled:NO];
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
    
    __weak typeof (self) selfie = self;
    if (![self.collectionView.collectionViewLayout isKindOfClass:[NHBalancedFlowLayout class]]) {
        NHBalancedFlowLayout *balancedLayout = [[NHBalancedFlowLayout alloc] init];
        [balancedLayout setPreferredRowSize:self.collectionView.frame.size.height/5];
        [balancedLayout setTargetIndexPath:indexPath];
        [self.collectionView setCollectionViewLayout:balancedLayout animated:YES completion:^(BOOL finished) {
            [sender setImage:[UIImage imageNamed:@"normal-layout"]];
            [sender setEnabled:YES];
            [selfie configurePinchGesture];
        }];
    } else {
        StickyHeaderFlowLayout *sticky = [[StickyHeaderFlowLayout alloc] init];
        [sticky setTargetIndexPath:indexPath];
        [self.collectionView setCollectionViewLayout:sticky animated:YES completion:^(BOOL finished) {
            [sender setImage:[UIImage imageNamed:@"balance-layout"]];
            [sender setEnabled:YES];
            [selfie configurePinchGesture];
        }];
    }
}

- (void)didTapSortButton:(id)sender {
    SortTableViewController *sort = [[SortTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [sort setSortingDelegate:self];
    [sort setSelectedSort:self.currentSort];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sort];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didTapUploadButton:(id)sender {
    if ([[ConnectionManager sharedManager] isGuestUser]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Demo account", nil) message:NSLocalizedString(@"You are viewing demo server at current.trovebox.com. Please login to your own account to upload.", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *loginAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Login", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[ConnectionManager sharedManager] logout];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:loginAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        DLFPhotosPickerViewController *photosPicker = [[DLFPhotosPickerViewController alloc] init];
        [photosPicker setPhotosPickerDelegate:self];
        [photosPicker setMultipleSelections:YES];
        [self presentViewController:photosPicker animated:YES completion:nil];
    }
}

#pragma mark - SortingDelegate

- (void)sortTableViewController:(id)sortTableViewController didSelectSort:(NSString *)sort {
    if (![self.currentSort isEqualToString:sort]) {
        self.currentSort = sort;
        [[NSUserDefaults standardUserDefaults] setObject:self.currentSort forKey:[NSString stringWithFormat:@"%@-%@", DLF_LAST_SELECTED_PHOTOS_SORT, self.item.itemId?:@""]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[SyncEngine sharedEngine] refreshPhotosInCollection:self.item.itemId collectionType:self.item.class sort:self.currentSort];
        
        [self selectSort:self.currentSort sortTableViewController:sortTableViewController];
    } else {
        [sortTableViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)selectSort:(NSString *)sort sortTableViewController:(id)sortTableViewController {
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
    
    if (sortTableViewController) {
        [sortTableViewController dismissViewControllerAnimated:YES completion:^{
            [((GroupedPhotosDataSource *)self.dataSource) sortBy:selectedSortKey ascending:ascending completion:nil];
//            if ([self.collectionView.collectionViewLayout respondsToSelector:@selector(needToResetFrames)]) {
//                [((id)self.collectionView.collectionViewLayout) setNeedToResetFrames:YES];
//                [self.collectionView.collectionViewLayout invalidateLayout];
//            }
            
        }];
    } else {
        [((GroupedPhotosDataSource *)self.dataSource) sortBy:selectedSortKey ascending:ascending completion:nil];
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

#pragma mark - Override

- (CollectionViewHeaderCellConfigureBlock)headerCellConfigureBlock {
    __weak typeof (self) selfie = self;
    void (^configureCell)(PhotosSectionHeaderView*, id,NSIndexPath*) = ^(PhotosSectionHeaderView* cell, id item, NSIndexPath *indexPath) {
        cell.section = indexPath.section;
        NSInteger section = indexPath.section;
        [cell setTitleLabelText:[item localizedDate]?:@""];
        CLLocation *location = [selfie locationSampleForSection:indexPath.section];
        if (location) {
            [[[LocationManager sharedManager] nameForLocation:location] continueWithBlock:^id(BFTask *task) {
                CLPlacemark *firstPlacemark = [((NSArray *)task.result) firstObject];
                NSString *placemark = [firstPlacemark locationString];
                if (cell.section == section) {
                    if (placemark && placemark.length > 0) {
                        [cell setLocationString:placemark];
                    } else {
                        [cell setLocationString:nil];
                    }
                }
                return nil;
            }];
        } else {
            [cell setLocationString:nil];
        }
    };
    return configureCell;
}

- (CollectionViewCellConfigureBlock)cellConfigureBlock {
    __weak typeof (self) selfie = self;
    void (^configureCell)(PhotoCell*, id) = ^(PhotoCell* cell, id item) {
        [cell setItem:item];
        if ([selfie.collectionView.collectionViewLayout isKindOfClass:[StickyHeaderFlowLayout class]]) {
            NSInteger numberOfColumns = [((StickyHeaderFlowLayout *)selfie.collectionView.collectionViewLayout) numberOfColumns];
            if (numberOfColumns > 1) {
                [cell setShowTitles:NO];
            } else {
                [cell setShowTitles:YES];
            }
        } else {
            [cell setShowTitles:NO];
        }
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

#pragma mark - <NHBalancedFlowLayoutDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(NHBalancedFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Photo *photo = [self.dataSource itemAtIndexPath:indexPath];
    CGSize size = CGSizeMake([photo.width floatValue], [photo.height floatValue]);
    CGFloat preferredHeight = 200;
    CGFloat width = preferredHeight * size.width/size.height;
    CGSize preferredSize = CGSizeMake(width, preferredHeight);
    //
    return preferredSize;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self pauseSyncing:YES];
    
    PhotoBoxCell *cell = (PhotoBoxCell *)[collectionView cellForItemAtIndexPath:indexPath];
    Photo *photo = (Photo *)cell.item;
    self.selectedItem = photo;
    
    [self openPhoto:cell.item];
}

- (void)openPhoto:(Photo *)photo{
    [self viewWillDisappear:YES];
    
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

#pragma mark - <CollectionViewChangeColumnsNumberGestureRecognizerDelegate>

- (void)didChangeNumberOfColumns:(NSInteger)newNumberOfColumns {
    for (PhotoCell *cell in self.collectionView.visibleCells) {
        if (newNumberOfColumns > 1) {
            [cell setShowTitles:NO];
        } else {
            [cell setShowTitles:YES];
        }
    }
}

#pragma mark - CustomAnimationTransitionFromViewControllerDelegate

- (UIImage *)imageToAnimate {
    if (self.selectedItem) {
        return ((PhotoBoxCell *)self.selectedCell).cellImageView.image;
    }
    if (self.headerImageView) {
        return self.headerImageView.imageView.image;
    }
    return nil;
}

- (CGRect)startRectInContainerView:(UIView *)containerView {
    if (self.selectedItem) {
        return [self.selectedCell convertFrameRectToView:containerView];
    }
    return [self.headerImageView.imageView convertFrameRectToView:containerView];
}

- (CGRect)endRectInContainerView:(UIView *)containerView {
    if (self.selectedItem) {
        NSIndexPath *indexPath = [self.dataSource indexPathOfItem:self.selectedItem];
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
    if (self.selectedItem) {
        return self.selectedCell;
    }
    return self.headerImageView;
}

- (UIView *)viewToAnimate {
    return nil;
}

#pragma mark - PhotosHorizontalScrollingViewControllerDelegate

- (void)photosHorizontalScrollingViewController:(PhotosHorizontalScrollingViewController *)viewController didChangePage:(NSInteger)page item:(Photo *)item {
    self.selectedItem = item;
    NSIndexPath *indexPath = [self.dataSource indexPathOfItem:self.selectedItem];
    if (indexPath) {
        if (indexPath.section < [self.collectionView numberOfSections]) {
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        }
    }
    
}

- (void)shouldClosePhotosHorizontalViewController:(PhotosHorizontalScrollingViewController *)controller {
    UICollectionViewCell *selectedCell = self.selectedCell;
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        if (cell != selectedCell) {
            [cell setAlpha:1];
        }
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self dismissViewControllerAnimated:YES completion:^{
        for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
            [cell setAlpha:1];
        }
        [selectedCell setAlpha:1];
        self.selectedItem = nil;
    }];
}

- (void)willDismissViewController:(PhotosHorizontalScrollingViewController *)controller {
    UICollectionViewCell *selectedCell = self.selectedCell;
    [selectedCell setAlpha:0];
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        if (cell != selectedCell) {
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
        location = [photo clLocation];
        if (location) {
            *stop = YES;
        }
    }];
    
    return location;
}

#pragma mark - DLFPhotosPickerViewControllerDelegate

- (void)photosPicker:(DLFPhotosPickerViewController *)photosPicker detailViewController:(DLFDetailViewController *)detailViewController didSelectPhotos:(NSArray *)photos {
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:photos.count];
    for (PHAsset *photo in photos) {
        DLFAsset *asset = [[DLFAsset alloc] init];
        asset.asset = photo;
        [assets addObject:asset];
    }
    TagsAlbumsPickerViewController *tagsalbumspicker = [[TagsAlbumsPickerViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [tagsalbumspicker setSelectedAssets:assets];
    [tagsalbumspicker setDelegate:self];
        
    [detailViewController.navigationController pushViewController:tagsalbumspicker animated:YES];
}

- (void)photosPickerDidCancel:(DLFPhotosPickerViewController *)photosPicker {
    [photosPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)photosPicker:(DLFPhotosPickerViewController *)photosPicker
detailViewController:(DLFDetailViewController *)detailViewController
       configureCell:(DLFPhotoCell *)cell
           indexPath:(NSIndexPath *)indexPath
               asset:(PHAsset *)asset {
    __block NSString *status;
    [[[DLFDatabaseManager manager] readConnection] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        status = [transaction objectForKey:asset.localIdentifier inCollection:uploadedCollectionName];
    }];
    
    UIImageView *uploadedView = (UIImageView *)[cell.contentView viewWithTag:UPLOADED_MARK_TAG];
    if ([status isEqualToString:photoUploadedKey]) {
        if (!uploadedView) {
            uploadedView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"uploaded"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [uploadedView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [uploadedView setTintColor:[UIColor whiteColor]];
            [cell.contentView addSubview:uploadedView];
            [uploadedView setTag:UPLOADED_MARK_TAG];
            [uploadedView.layer setShadowColor:[[UIColor blackColor] CGColor]];
            [uploadedView.layer setShadowRadius:1];
            [uploadedView.layer setShadowOffset:CGSizeMake(0, 1)];
            [uploadedView.layer setShadowOpacity:1];
            [uploadedView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
            [uploadedView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
            [uploadedView autoSetDimensionsToSize:CGSizeMake(30, 30)];
        }
        [uploadedView setHidden:NO];
    } else {
        [uploadedView setHidden:YES];
    }
}

#pragma mark - Tags Albums Picker View Controller Delegate

- (void)tagsAlbumsPickerViewController:(TagsAlbumsPickerViewController *)tagsAlbumsPickerViewController didFinishSelectTagsAndAlbum:(NSArray *)assets {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        CLS_LOG(@"+++ Gonna show upload view");
        UploadViewController *uploadVC = [[UploadViewController alloc] init];
        [uploadVC setDelegate:self];
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:uploadVC];
        
        self.uploadViewController = uploadVC;
        
        [self presentViewController:navCon animated:YES completion:^{
            
            for (DLFAsset *asset in assets) {
                [[DLFImageUploader sharedUploader] queueAsset:asset];
            }
            
            BFTask *uploadingTask = [[DLFImageUploader sharedUploader] uploadingTask];
            [uploadingTask continueWithBlock:^id(BFTask *t) {
                BFTask *task = [BFTask taskWithResult:nil];
                NSMutableArray *phAssets = [NSMutableArray arrayWithCapacity:assets.count];
                for (DLFAsset *asset in assets) {
                    if (asset.scaleAfterUpload) {
                        [phAssets addObject:asset.asset];
                        task = [task continueWithBlock:^id(BFTask *task) {
                            return [[PHPhotoLibrary sharedPhotoLibrary] resizeAndCreateNewAsset:asset.asset scale:0.5];
                        }];
                    }
                }
                
                if (phAssets.count > 0) {
                    return [task continueWithBlock:^id(BFTask *task) {
                        return [[PHPhotoLibrary sharedPhotoLibrary] deleteAssets:phAssets];
                    }];
                }
                
                return task;
            }];
        }];
    }];
}

#pragma mark - UploadViewControllerDelegate

- (void)uploadViewControllerDidClose:(UploadViewController *)uploadViewController {
    CLS_LOG(@"+++ dismissing upload");
    [uploadViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)uploadViewControllerDidFinishUploading:(UploadViewController *)uploadViewController {
    [uploadViewController dismissViewControllerAnimated:YES completion:^{
        CLS_LOG(@"+++ did finish uploading and closing upload vc");
           [self refresh];
    }];
}

#pragma mark - Upload Notification

- (void)uploadNumberChangeNotification:(NSNotification *)notification {
    int numberOfUploads = [notification.userInfo[kNumberOfUploadsKey] intValue];
    if (numberOfUploads == 0 && !self.presentedViewController) {
        if ([(YapDataSource *)self.dataSource pause]) {
            CLS_LOG(@"+++ upload done but paused");
            [self setDoneUploadingNeedRefresh:YES];
        } else {
            [self setDoneUploadingNeedRefresh:NO];
            [self refresh];
        }
        
    }
}

@end
