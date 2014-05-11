//
//  PhotosHorizontalScrollingViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosHorizontalScrollingViewController.h"

#import "PhotoBoxModel.h"
#import "PhotoZoomableCell.h"
#import "Photo.h"
#import "NPRImageDownloader.h"
#import "OriginalImageDownloaderViewController.h"
#import "PhotoBoxImage.h"
#import "UIViewController+Additionals.h"
#import "UIView+Additionals.h"
#import "PhotoSharingManager.h"
#import "PhotoInfoViewController.h"
#import "DownloadedImageManager.h"

@interface PhotosHorizontalScrollingViewController () <UIGestureRecognizerDelegate, PhotoZoomableCellDelegate, PhotoInfoViewControllerDelegate, UIAlertViewDelegate> {
    BOOL shouldHideNavigationBar;
}

@property (nonatomic, assign) NSInteger previousPage;
@property (nonatomic, assign) BOOL justOpened;
@property (nonatomic, strong) UIView *darkBackgroundView;
@property (nonatomic, strong) UIView *backgroundViewControllerView;
@property (nonatomic, strong) UIView *photoInfoBackgroundGradientView;
@property (nonatomic, strong) UIButton *infoButton;

@end

@implementation PhotosHorizontalScrollingViewController

- (void)viewDidLoad
{
    self.disableFetchOnLoad = YES;
    [super viewDidLoad];
    
    self.numberOfColumns = 0;
    self.previousPage = 0;
    self.justOpened = YES;
    
    ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView registerClass:[PhotoZoomableCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
	
    [self.collectionView setAlwaysBounceVertical:NO];
    [self.collectionView setAlwaysBounceHorizontal:YES];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self adjustCollectionViewWidthToHavePhotosSpacing];
    
    [self.dataSource setCellIdentifier:[self cellIdentifier]];
    
    [self.collectionView reloadData];
        
    UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce:)];
    [tapOnce setDelegate:self];
    [tapOnce setNumberOfTapsRequired:1];
    [self.collectionView addGestureRecognizer:tapOnce];
    
    [self showLoadingBarButtonItem:NO];
    
    self.darkBackgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.darkBackgroundView setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [self.collectionView setBackgroundView:self.darkBackgroundView];
    
    self.resourceType = PhotoResource;
}

- (void)viewWillAppear:(BOOL)animated {
    [self insertBackgroundSnapshotView];
    [self scrollToFirstShownPhoto];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:self.collectionView afterDelay:1];
    [self showInfoButton:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showInfoButton:NO animated:YES];
}

- (void)adjustCollectionViewWidthToHavePhotosSpacing {
    self.collectionView.frame = ({
        CGRect frame = self.collectionView.frame;
        frame.size.width += PHOTO_SPACING;
        frame;
    });
    self.collectionView.contentInset = ({
        UIEdgeInsets inset = self.collectionView.contentInset;
        inset.top = 0;
        inset.right += PHOTO_SPACING;
        inset;
    });
}

- (void)scrollToFirstShownPhoto {
    PBX_LOG(@"");
    NSInteger numberOfItems = [self.dataSource numberOfItems];
    NSInteger firstPhotoIndex = self.firstShownPhotoIndex;
    if (numberOfItems>firstPhotoIndex) {
        shouldHideNavigationBar = YES;
        self.previousPage = self.firstShownPhotoIndex-1;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.firstShownPhotoIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    } else {
        PBX_LOG(@"Error scroll to first shown photo. Number of items = %d. First shown index = %d.", [self.dataSource numberOfItems], self.firstShownPhotoIndex);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHideDownloadButton:(BOOL)hideDownloadButton{
    _hideDownloadButton = hideDownloadButton;
    
    [self showLoadingBarButtonItem:NO];
}

#pragma mark - Orientation

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Override setup

- (NSString *)cellIdentifier {
    return @"photoZoomableCell";
}

- (void)setupPinchGesture {
    // pinch not needed
}

- (void)setupRefreshControl {
    // refresh control not needed
}

- (NSString *)resourceId {
    return self.item.itemId;
}

- (NSString *)groupKey {
    return nil;
}

- (NSArray *)sortDescriptors {
    return nil;
}

- (Class)resourceClass {
    return [Photo class];
}

- (int)pageSize {
    return 0;
}

- (CollectionViewCellConfigureBlock)cellConfigureBlock {
    void (^configureCell)(PhotoZoomableCell*, id) = ^(PhotoZoomableCell* cell, id item) {
        [cell setItem:item];
        [cell setDelegate:self];
        [cell setGrayscaleAndZoom:NO animated:NO];
    };
    return configureCell;
}

#pragma mark - Interactive Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gestureRecognizer;
        if (tap.numberOfTapsRequired == 1) {
            if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                UITapGestureRecognizer *other = (UITapGestureRecognizer *)otherGestureRecognizer;
                if (other.numberOfTapsRequired == 2) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)tapOnce:(UITapGestureRecognizer *)tapGesture {
    [self toggleNavigationBarHidden];
    if (self.navigationController.navigationBar.alpha == 0) {
        [self darkenBackground];
    } else [self brightenBackground];
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return PHOTO_SPACING;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.frame.size.width-PHOTO_SPACING;
    CGFloat height = collectionView.frame.size.height - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom;
    return CGSizeMake(width, height);
}

#pragma mark - Scroll view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // empty to override superclass
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = [self currentCollectionViewPage:scrollView];
    if (self.previousPage != page) {
        if (!shouldHideNavigationBar) {
            [self hideNavigationBar];
            [self darkenBackground];
        } else {
            shouldHideNavigationBar = NO;
        }
        
        self.previousPage = page;
        if (!self.justOpened) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosHorizontalScrollingViewController:didChangePage:item:)]) {
                //NSManagedObject *photo = [self.dataSource managedObjectItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0]];
                id photo = [self.dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0]];
                [self.delegate photosHorizontalScrollingViewController:self didChangePage:page item:photo];
            }
            [self insertBackgroundSnapshotView];
        } else {
            self.justOpened = NO;
            [self showHintIfNeeded];
        }
    }
}

- (void)insertBackgroundSnapshotView {
    if (self.backgroundViewControllerView) {
        [self.backgroundViewControllerView removeFromSuperview];
    }
    UIView *bgView = [self.delegate snapshotView];
    self.backgroundViewControllerView = bgView;
    [self.backgroundViewControllerView setBackgroundColor:[UIColor whiteColor]];
    CGRect frame = ({
        CGRect frame = self.backgroundViewControllerView.frame;
        frame.origin = self.collectionView.frame.origin;
        frame;
    });
    [self.backgroundViewControllerView setFrame:frame];
    UIView *whiteView = [[UIView alloc] initWithFrame:[self.delegate selectedItemRectInSnapshot]];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    [self.backgroundViewControllerView addSubview:whiteView];
    [self.collectionView.superview insertSubview:self.backgroundViewControllerView belowSubview:self.collectionView];
}

- (NSInteger)currentCollectionViewPage:(UIScrollView *)scrollView{
    if (self.justOpened) {
        return self.firstShownPhotoIndex;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.firstShownPhotoIndex = page;
    return page;
}

- (void)darkenBackground {
    [self setBackgroundBrightness:0];
}

- (void)brightenBackground {
    [self setBackgroundBrightness:1];
}

- (void)setBackgroundBrightness:(float)brightness {
    [UIView animateWithDuration:0.4 animations:^{
        [self.darkBackgroundView setBackgroundColor:[UIColor colorWithWhite:brightness alpha:1]];
    }];
}

#pragma mark - Zoomable Cell delegate

- (void)didCancelClosingPhotosHorizontalViewController {
    
}

- (void)didClosePhotosHorizontalViewController{
    PBX_LOG(@"Popping from horizontal view controller");
    [[self currentCell] setClosingViewController:YES];
    [self.delegate photosHorizontalWillClose];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didDragDownWithPercentage:(float)progress {
    [self.darkBackgroundView setAlpha:MIN(1-progress+0.3, 1)];
}

#pragma mark - Button

- (void)infoButtonTapped:(id)sender {
    [sender setEnabled:NO];
    [self showInfoButton:NO animated:YES];
    
    BOOL isGrayscaled = [[self currentCell] isGrayscaled];
    [self setNavigationBarHidden:!isGrayscaled animated:YES];
    [[self currentCell] setGrayscaleAndZoom:!isGrayscaled];
    
    UIView *gradientView = [[self currentCell] addTransparentGradientWithStartColor:[UIColor blackColor] fromStartPoint:CGPointMake(0, 1) endPoint:CGPointMake(0.7, 0.5)];
    self.photoInfoBackgroundGradientView = gradientView;
    [gradientView setAlpha:0];
    
    PhotoInfoViewController *photoInfo = [[PhotoInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [photoInfo setPhoto:[[self currentCell] item]];
    [photoInfo setDelegate:self];
    [self addChildViewController:photoInfo];
    [self.view addSubview:photoInfo.view];
    [photoInfo.view setOriginY:CGRectGetHeight(self.collectionView.frame)];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [gradientView setAlpha:1];
        [photoInfo.view setOriginY:0];
    } completion:^(BOOL finished) {
        [sender setEnabled:YES];
    }];
}

- (void)viewOriginalButtonTapped:(id)sender {
    PBX_LOG(@"");
    if ([[DownloadedImageManager sharedManager] photoHasBeenDownloaded:[self currentPhoto]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Re-download", nil) message:NSLocalizedString(@"This photo has been downloaded to your phone. Would you like to download it again?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        [alert show];
    } else {
        [self continueDownloadOriginalImage];
    }
}

- (void)continueDownloadOriginalImage {
    if (![[NPRImageDownloader sharedDownloader] downloadViewControllerInitBlock]) {
        [[NPRImageDownloader sharedDownloader] setDownloadViewControllerInitBlock:^id{
            OriginalImageDownloaderViewController *original = [[OriginalImageDownloaderViewController alloc] initWithStyle:UITableViewStylePlain];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:original];
            return nav;
        }];
    }
    
    Photo *currentPhoto = [self currentPhoto];
    
    if (currentPhoto.pathOriginal) {
        [[NPRImageDownloader sharedDownloader] queuePhoto:currentPhoto thumbnail:[self currentCell].thisImageview.image];
    }
}

- (Photo *)currentPhoto {
    return (Photo *)[[self currentCell] item];
}

- (void)actionButtonTapped:(id)sender {
    PBX_LOG(@"Sharing tapped");
    [self showLoadingBarButtonItem:YES];
    PhotoZoomableCell *cell = (PhotoZoomableCell *)[[self.collectionView visibleCells] objectAtIndex:0];
    Photo *photo = cell.item;
    __weak PhotosHorizontalScrollingViewController *weakSelf = self;
    [[PhotoSharingManager sharedManager] sharePhoto:photo image:cell.cellImageView.image tokenFetchedBlock:^(id token) {
        [weakSelf showLoadingBarButtonItem:NO];
        if (token) {
            [[NPRNotificationManager sharedManager] hideNotification];
        } else {
            [[NPRNotificationManager sharedManager] postErrorNotificationWithText:NSLocalizedString(@"Sharing token cannot be fetched", nil) duration:3];
        }
    } completion:nil];
}

- (void)showLoadingBarButtonItem:(BOOL)show {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"download.png"] style:UIBarButtonItemStylePlain target:self action:@selector(viewOriginalButtonTapped:)];
    UIBarButtonItem *shareButton;
    
    if (show) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [indicatorView setColor:[[[[UIApplication sharedApplication] delegate] window] tintColor]];
        shareButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
        [indicatorView startAnimating];
    } else {
        shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
    }
    if (!self.hideDownloadButton) [self.navigationItem setRightBarButtonItems:@[shareButton, rightButton]];
    else [self.navigationItem setRightBarButtonItems:@[shareButton]];
}

- (void)showInfoButton:(BOOL)show animated:(BOOL)animated{
    if (show) {
        [self.infoButton setAlpha:0];
        if (animated) {
            [UIView animateWithDuration:0.5 animations:^{
                [self.infoButton setAlpha:1];
            }];
        } else [self.infoButton setAlpha:1];
    }
    else {
        if (animated) {
            [UIView animateWithDuration:0.5 animations:^{
                [self.infoButton setAlpha:0];
            }];
        } else [self.infoButton setAlpha:1];
    }
}

- (UIButton *)infoButton {
    if (!_infoButton) {
        _infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [_infoButton setShowsTouchWhenHighlighted:YES];
        [_infoButton setImage:[[UIImage imageNamed:@"info.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_infoButton setBackgroundColor:[UIColor clearColor]];
        [_infoButton addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.view addSubview:_infoButton];
        [_infoButton setPositionFromEdge:MNCUIViewRightEdge margin:10];
        [_infoButton setPositionFromEdge:MNCUIViewBottomEdge margin:10];
    }
    return _infoButton;
}

#pragma mark - Custom Animation Transition Delegate

- (PhotoZoomableCell *)currentCell {
    return [self.collectionView visibleCells][0];
}

- (UIView *)viewToAnimate {
    return [self currentCell].thisImageview;
}

- (UIImage *)imageToAnimate {
    return nil;
}

- (CGRect)startRectInContainerView:(UIView *)view {
    PhotoZoomableCell *cell = [self currentCell];
    return cell.thisImageview.frame;
}

- (CGRect)endRectInContainerView:(UIView *)view {
    return CGRectZero;
}

#pragma mark - Hint

- (void)showHintIfNeeded {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:PBX_DID_SHOW_SCROLL_UP_AND_DOWN_TO_CLOSE_FULL_SCREEN_PHOTO]) {
        PhotoZoomableCell *currentCell = [self currentCell];
        if (currentCell) {
            [currentCell doTeasingGesture];
        }
    }
}

#pragma mark - Photo Info View Controller

- (void)photoInfoViewControllerDidClose:(PhotoInfoViewController *)photoInfo {
    UIViewController *childVC = [self childViewControllers][0];
    [childVC removeFromParentViewController];
    [UIView animateWithDuration:0.5 animations:^{
        [childVC.view setOriginY:CGRectGetHeight(self.collectionView.frame)];
        [self.photoInfoBackgroundGradientView setAlpha:0];
    } completion:^(BOOL finished) {
        [childVC.view removeFromSuperview];
        [self.photoInfoBackgroundGradientView removeFromSuperview];
        [[self currentCell] setGrayscaleAndZoom:NO animated:YES];
        [self showInfoButton:YES animated:YES];
    }];
}

- (void)photoInfoViewController:(PhotoInfoViewController *)photoInfo didDragToClose:(CGFloat)progress {
    [[[self currentCell] grayImageView] setAlpha:1-progress];
}

#pragma mark - Alert 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self continueDownloadOriginalImage];
    }
}

@end
