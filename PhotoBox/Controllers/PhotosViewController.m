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

#import "PhotosHorizontalScrollingYapBackedViewController.h"
#import "SettingsTableViewController.h"

#import "CollectionViewSelectCellGestureRecognizer.h"

#import "UIView+Additionals.h"
#import "NSString+Additionals.h"
#import "UIViewController+Additionals.h"

#import <JASidePanelController.h>
#import "UIViewController+DelightfulViewControllers.h"

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

#import <TMCache.h>

#import "FallingTransitioningDelegate.h"

#import "PhotosPickerViewController.h"

#import "DelightfulCache.h"

#import "DLFImageUploader.h"

#import "UploadViewController.h"

#import "TagsAlbumsPickerViewController.h"

#import "DLFAsset.h"

#import "ShowFullScreenTransitioningDelegate.h"

#import "NSAttributedString+DelighftulFonts.h"

@interface PhotosViewController () <UICollectionViewDelegateFlowLayout, PhotosHorizontalScrollingViewControllerDelegate, CTAssetsPickerControllerDelegate, UINavigationControllerDelegate, TagsAlbumsPickerViewControllerDelegate>

@property (nonatomic, strong) PhotoBoxCell *selectedCell;
@property (nonatomic, assign) CGRect selectedItemRect;
@property (nonatomic, strong) CollectionViewSelectCellGestureRecognizer *selectGesture;
@property (nonatomic, assign) BOOL observing;
@property (nonatomic, weak) HeaderImageView *headerImageView;
@property (nonatomic, weak) NoPhotosView *noPhotosView;
@property (nonatomic, strong) NSMutableArray *uploadingPhotos;

@property (nonatomic, strong) FallingTransitioningDelegate *fallingTransitioningDelegate;
@property (nonatomic, strong) ShowFullScreenTransitioningDelegate *transitionDelegate;

@property (nonatomic, strong) UploadViewController *uploadViewController;

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
    self.resourceType = PhotoResource;
    self.relationshipKeyPathWithItem = @"albums";
    
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.numberOfColumns = 3;
    
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    
    //[self.collectionView.viewForBaselineLayout.layer setSpeed:0.8f];
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    [self.collectionView registerClass:[PhotosSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[self sectionHeaderIdentifier]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeNumberOfUploads:) name:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil];
    
    //self.selectGesture = [[CollectionViewSelectCellGestureRecognizer alloc] initWithCollectionView:self.collectionView];
    
    [self setupRightBarButtonsWithSettings:YES];
    
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

- (void)setupRightBarButtonsWithSettings:(BOOL)showSetting {
    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [settingButton setImage:[[UIImage imageNamed:@"setting.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spaceItem setWidth:15];
    
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 23)];
    [cameraButton setImage:[[UIImage imageNamed:@"upload.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(cameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cameraBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
    
    
    if (showSetting) {
        [self.navigationItem setRightBarButtonItems:@[settingBarButtonItem, spaceItem, cameraBarButtonItem, spaceItem]];
    } else {
        [self.navigationItem setRightBarButtonItems:@[cameraBarButtonItem, spaceItem]];
    }
}

#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    
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

- (Class)resourceClass {
    return [Photo class];
}

- (NSString *)resourceId {
    return self.item.itemId;
}

- (Class)dataSourceClass {
    return [GroupedPhotosDataSource class];
}

/*
- (void)refresh {
    if ([self itemIsDownloadHistoryOrFavorites]) {
        Album *album = (Album *)self.item;
        [self.dataSource removeAllItems];
        [self.dataSource addItems:album.photos];
        [self.refreshControl endRefreshing];
        
        [self addOrRemoveHeaderView];
        
        if ([self.dataSource items].count == 0) {
            if (!self.noPhotosView) {
                NoPhotosView *noPhotos = (NoPhotosView *)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NoPhotosView class]) owner:nil options:nil] firstObject];
                [noPhotos setFrame:self.view.bounds];
                [self.view addSubview:noPhotos];
                self.noPhotosView = noPhotos;
            }
            NSString *text;
            if ([album.albumId isEqualToString:PBX_downloadHistoryIdentifier]) {
                text = NSLocalizedString(@"Photos you have downloaded and saved to Camera Roll will appear here.", nil);
            } else if ([album.albumId isEqualToString:PBX_favoritesAlbumIdentifier]) {
                text = NSLocalizedString(@"Favorited photos will appear here. Favorited photos are not saved to Camera Roll and Trovebox server.", nil);
            }
            [self.noPhotosView.textLabel setText:text];
            
        } else {
            [self.noPhotosView removeFromSuperview];
        }
        return;
    }
    
    [self addOrRemoveHeaderView];
    [self.noPhotosView removeFromSuperview];
    
    [super refresh];
}
 */


- (void)didLoadDataFromCache {
    [self addOrRemoveHeaderView];
    [self.noPhotosView removeFromSuperview];
    [self restoreContentInset];
    
    NSInteger count = [self.dataSource numberOfItems];
    NSInteger totalPhotos = [(id)self.item totalPhotos];
    [self setPhotosCount:count max:totalPhotos];
    
    self.page = ceil((double)count/(double)self.pageSize);
    self.totalPages = ceil((double)totalPhotos/(double)self.pageSize);
    self.totalItems = totalPhotos;
    
    [self.collectionView setContentOffset:CGPointMake(0, -self.collectionView.contentInset.top)];
}

- (void)addOrRemoveHeaderView {
    if ([self.item isKindOfClass:[Album class]]) {
        Album *a = (Album *)self.item;
        if (![a.albumId isEqualToString:PBX_allAlbumIdentifier] && ![a.albumId isEqualToString:PBX_downloadHistoryIdentifier] && ![a.albumId isEqualToString:PBX_favoritesAlbumIdentifier]) {
            if (!self.headerImageView) {
                HeaderImageView *head = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([HeaderImageView class]) owner:nil options:nil] firstObject];
                [self.view insertSubview:head aboveSubview:self.collectionView];
                self.headerImageView = head;
                CGFloat headerHeight = self.headerImageView.intrinsicContentSize.height;
                [self.headerImageView setFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), headerHeight-64)];
                                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImageViewTapped:)];
                [self.headerImageView addGestureRecognizer:tap];
            }
            
            UIImage *placeholderImage = a.albumThumbnailImage;
            if (!placeholderImage) {
                placeholderImage = a.albumCover.asAlbumCoverImage;
                if (!placeholderImage) {
                    placeholderImage = a.albumCover.placeholderImage;
                }
            }
            [self.headerImageView.imageView npr_setImageWithURL:a.albumCover.pathOriginal placeholderImage:placeholderImage];
            [self setTitle:a.name];
            a.albumCover.asAlbumCoverURL = a.coverURL;
            
            CGFloat headerHeight = self.headerImageView.intrinsicContentSize.height;
            self.collectionView.contentInset = ({
                UIEdgeInsets inset = self.collectionView.contentInset;
                inset.top = headerHeight;
                inset;
            });
            
            [self.collectionView setBackgroundColor:[UIColor clearColor]];
            StickyHeaderFlowLayout *layout = (StickyHeaderFlowLayout *)self.collectionView.collectionViewLayout;
            [layout setTopOffsetAdjustment:headerHeight-CGRectGetHeight(self.navigationController.navigationBar.frame) - 20];
            
            return;
        }
        
    }
    
    StickyHeaderFlowLayout *layout = (StickyHeaderFlowLayout *)self.collectionView.collectionViewLayout;
    [layout setTopOffsetAdjustment:0];
    
    [self.headerImageView removeFromSuperview];
    self.headerImageView = nil;
    [self restoreContentInset];
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
    }
    
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

- (void)processPaginationFromObjects:(id)objects {
    [super processPaginationFromObjects:objects];
    
    [(id)self.item setTotalPhotos:self.totalItems];
}

- (void)userDidLogout {
    self.item = [Album allPhotosAlbum];
    [self addOrRemoveHeaderView];
    [self setTitle:NSLocalizedString(@"Gallery", nil)];
}

#pragma mark - Do something

- (void)settingButtonTapped:(id)sender {
    SettingsTableViewController *settings = [[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    if (!self.fallingTransitioningDelegate) {
        FallingTransitioningDelegate *falling = [[FallingTransitioningDelegate alloc] init];
        self.fallingTransitioningDelegate = falling;
        [self.fallingTransitioningDelegate setSpeed:10];
    }
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:settings];
    [navCon setModalPresentationStyle:UIModalPresentationCustom];
    [navCon setTransitioningDelegate:self.fallingTransitioningDelegate];
    [self presentViewController:navCon animated:YES completion:nil];
}

- (void)cameraButtonTapped:(id)sender {
    PhotosPickerViewController *picker = [[PhotosPickerViewController alloc] init];
    picker.delegate = self;
    [picker setAssetsFilter:[ALAssetsFilter allPhotos]];
    if (!self.fallingTransitioningDelegate) {
        FallingTransitioningDelegate *falling = [[FallingTransitioningDelegate alloc] init];
        self.fallingTransitioningDelegate = falling;
        //[self.fallingTransitioningDelegate setSpeed:10];
    }
    [picker setTransitioningDelegate:self.fallingTransitioningDelegate];
    [picker setModalPresentationStyle:UIModalPresentationCustom];
    [self presentViewController:picker animated:YES completion:nil];
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

- (void)setNumberOfColumns:(int)numberOfColumns {
    if (_numberOfColumns != numberOfColumns) {
        _numberOfColumns = numberOfColumns;
                
        DelightfulLayout *layout = (DelightfulLayout *)self.collectionView.collectionViewLayout;
        [layout setNumberOfColumns:_numberOfColumns];
    }
}

- (void)didFetchItems {
    NSInteger count = [self.dataSource numberOfItems];
    [self setPhotosCount:(int)count max:self.totalItems];
}

- (NSString *)refreshKey {
    return [NSString stringWithFormat:@"%@-%@", NSStringFromClass([self.item class]), [self.item itemId]];
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

- (void)headerImageViewTapped:(id)sender {
    self.selectedCell = nil;
    Album *album = (Album *)self.item;
    [self openPhoto:(id)album.albumCover];
}

- (void)reloadButtonTapped:(id)sender {
    [self.uploadViewController showReloadButtons:NO];
    [self.uploadViewController startUpload];
}

- (void)cancelButtonTapped:(id)sender {
    [[DLFImageUploader sharedUploader] clearFailUploads];
    [self closeUploadView];
}

- (void)closeUploadView {
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat offset = CGRectGetHeight(self.uploadViewController.view.frame) + self.collectionView.contentInset.top;
        
        self.uploadViewController.view.frame = CGRectOffset(self.uploadViewController.view.frame, 0, -offset);
        self.collectionView.frame = CGRectMake(0, 0, self.collectionView.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.uploadViewController willMoveToParentViewController:nil];
        [self.uploadViewController removeFromParentViewController];
        [self.uploadViewController.view removeFromSuperview];
        [self.uploadViewController didMoveToParentViewController:nil];
        self.uploadViewController = nil;
        
        [self refresh];
    }];
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
    
    PhotoBoxCell *cell = (PhotoBoxCell *)[collectionView cellForItemAtIndexPath:indexPath];
    Photo *photo = (Photo *)cell.item;
    if (photo.asset) {
        return;
    }
    self.selectedCell = cell;
    [self setSelectedItemRectAtIndexPath:indexPath];
    
    [self openPhoto:cell.item];
}

- (void)openPhoto:(Photo *)photo{
    PhotosHorizontalScrollingYapBackedViewController *destination = [[PhotosHorizontalScrollingYapBackedViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init] groupedViewMapping:((YapDataSource *)self.dataSource).selectedViewMapping];
    [destination setFirstShownPhoto:photo];
    [destination setDelegate:self];
    [self setupBackNavigationItemTitle];
    if (!self.transitionDelegate) {
        self.transitionDelegate = [[ShowFullScreenTransitioningDelegate alloc] init];
    }
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:destination];
    [navCon setTransitioningDelegate:self.transitionDelegate];
    [navCon setModalPresentationStyle:UIModalPresentationCustom];
    
    {
        UIButton *label = [[UIButton alloc] init];
        NSMutableAttributedString *leftArrow = [[NSAttributedString symbol:dlf_icon_arrow_left3 size:25] mutableCopy];
        [leftArrow addAttribute:NSBaselineOffsetAttributeName value:@(-4) range:NSMakeRange(0, leftArrow.string.length)];
        [leftArrow addAttribute:NSForegroundColorAttributeName value:self.view.tintColor range:NSMakeRange(0, leftArrow.string.length)];
        NSAttributedString *titleAttr = [[NSAttributedString alloc] initWithString:self.title?:NSLocalizedString(@"Back", nil) attributes:@{NSForegroundColorAttributeName: self.view.tintColor, NSBaselineOffsetAttributeName: @(1)}];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:leftArrow];
        [attr appendAttributedString:titleAttr];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CustomAnimationTransitionFromViewControllerDelegate

- (UIImage *)imageToAnimate {
    if (self.selectedCell) {
        return self.selectedCell.cellImageView.image;
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
        CGRect originalPosition = CGRectOffset(self.selectedItemRect, 0, self.collectionView.contentInset.top);
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
            [self setSelectedItemRectAtIndexPath:indexPath];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            self.selectedCell = (PhotoBoxCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        }
    }
    
}

- (UIView *)snapshotView {
    return [self.view snapshotViewAfterScreenUpdates:YES];
}

- (CGRect)selectedItemRectInSnapshot {
    return [self endRectInContainerView:nil];
}

- (void)shouldClosePhotosHorizontalViewController:(PhotosHorizontalScrollingViewController *)controller {
    [self setNavigationBarHidden:NO animated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.selectedCell setAlpha:1];
    }];
}

- (void)willDismissViewController:(PhotosHorizontalScrollingViewController *)controller {
    NSLog(@"setting alpha 0 to seleced cell");
    [self.selectedCell setAlpha:0];
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

#pragma mark - CTAssetsPickerControllerDelegate

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldShowAssetsGroup:(ALAssetsGroup *)group {
    return [group numberOfAssets] > 0?YES:NO;
}


- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    TagsAlbumsPickerViewController *tagsalbumspicker = [[TagsAlbumsPickerViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [tagsalbumspicker setDelegate:self];
    [tagsalbumspicker setSelectedAssets:[DLFAsset assetsArrayFromALAssetArray:assets]];
    [picker pushViewController:tagsalbumspicker animated:YES];
}

- (void)didChangeNumberOfUploads:(NSNotification *)notification {
    NSInteger uploads = [notification.userInfo[kNumberOfUploadsKey] integerValue];
    NSInteger fails = [[DLFImageUploader sharedUploader] numberOfFailUpload];
    
    if (uploads == 0) {
        if (fails == 0) {
            [self closeUploadView];
        } else {
            [self refresh];
            [self.uploadViewController showReloadButtons:YES];
            [self.uploadViewController.reloadButton addTarget:self action:@selector(reloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.uploadViewController.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

#pragma mark - Tags Albums Picker View Controller Delegate

- (void)tagsAlbumsPickerViewController:(TagsAlbumsPickerViewController *)tagsAlbumsPickerViewController didFinishSelectTagsAndAlbum:(NSArray *)assets {
    [self dismissViewControllerAnimated:YES completion:^{
        UploadViewController *uploadVC = [[UploadViewController alloc] init];
        [uploadVC setUploads:assets];
        [uploadVC.view setFrame:CGRectMake(0, -(UPLOAD_BAR_HEIGHT+UPLOAD_ITEM_WIDTH), CGRectGetWidth(self.view.frame), (UPLOAD_BAR_HEIGHT+UPLOAD_ITEM_WIDTH))];
        [uploadVC willMoveToParentViewController:self];
        [self addChildViewController:uploadVC];
        [self.view addSubview:uploadVC.view];
        [uploadVC didMoveToParentViewController:self];
        
        self.uploadViewController = uploadVC;
        
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat offset = CGRectGetHeight(uploadVC.view.frame) + self.collectionView.contentInset.top;
            CGFloat offsetWithoutInset = offset - self.collectionView.contentInset.top;
            uploadVC.view.frame = CGRectOffset(uploadVC.view.frame, 0, offset);
            self.collectionView.frame = CGRectMake(0, offsetWithoutInset, self.collectionView.frame.size.width, CGRectGetHeight(self.collectionView.frame)-offsetWithoutInset);
        } completion:^(BOOL finished) {
            [uploadVC startUpload];
        }];
    }];
}

@end
