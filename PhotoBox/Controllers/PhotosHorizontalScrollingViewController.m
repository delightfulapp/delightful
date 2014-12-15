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
#import "FavoritesManager.h"
#import "TransitionToInfoDelegate.h"
#import "TransitionToInfoPresentationController.h"
#import "NPRNotificationManager.h"

#import <SVProgressHUD.h>

@interface PhotosHorizontalScrollingViewController () <UIGestureRecognizerDelegate, PhotoZoomableCellDelegate, PhotoInfoViewControllerDelegate, UIAlertViewDelegate, UICollectionViewDelegateFlowLayout, TransitionToInfoPresentationControllerPresentingDelegate> {
    BOOL shouldHideNavigationBar;
}

@property (nonatomic, assign) NSInteger previousPage;
@property (nonatomic, strong) UIView *darkBackgroundView;
@property (nonatomic, strong) UIView *backgroundViewControllerView;
@property (nonatomic, assign) NSInteger firstShownPhotoIndex;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitionToInfoDelegate;

@end

@implementation PhotosHorizontalScrollingViewController

+ (PhotosHorizontalScrollingViewController *)defaultController {
    PhotosHorizontalLayout *layout = [[PhotosHorizontalLayout alloc] init];
    PhotosHorizontalScrollingViewController *controller = [[PhotosHorizontalScrollingViewController alloc] initWithCollectionViewLayout:layout];
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.previousPage = 0;
    
    [self setupDataSource];
    
    [self.collectionView setDelegate:self];
    ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView registerClass:[PhotoZoomableCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    [self.collectionView setAlwaysBounceVertical:NO];
    [self.collectionView setAlwaysBounceHorizontal:YES];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self adjustCollectionViewWidthToHavePhotosSpacing];
    
    [self.collectionView reloadData];
    
    [self showLoadingBarButtonItem:NO];
        
    UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce:)];
    [tapOnce setDelegate:self];
    [tapOnce setNumberOfTapsRequired:1];
    [self.collectionView addGestureRecognizer:tapOnce];
    
    self.darkBackgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.darkBackgroundView setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [self.collectionView setBackgroundView:self.darkBackgroundView];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.dataSource) {
        [self setupDataSource];
    }
    [self scrollToFirstShownPhoto];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:self.collectionView afterDelay:0.5];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showLoadingBarButtonItem:NO];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    self.dataSource = nil;
}

- (void)dealloc {
    self.dataSource = nil;
}

- (void)setupDataSource {
    
}

- (NSString *)cellIdentifier {
    return @"horizontal-photos-cell";
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
    NSIndexPath *indexPath = [self.dataSource indexPathOfItem:self.firstShownPhoto];
    self.previousPage = indexPath.item;
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForItem:[self currentCollectionViewPage:self.collectionView] inSection:0];
    [((PhotosHorizontalLayout *)self.collectionView.collectionViewLayout) setTargetIndexPath:currentIndexPath];
    [self.collectionView.collectionViewLayout invalidateLayout];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:currentIndexPath];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self toggleNavigationBarHidden];
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
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

- (void)tapOnce:(id)sender {
    [self toggleFullScreen];
}

- (void)toggleFullScreen {
    if (self.navigationController.navigationBar.alpha == 1) {
        [self setFullScreen:YES];
    } else {
        [self setFullScreen:NO];
    }
}

- (void)setFullScreen:(BOOL)fullScreen {
    [[UIApplication sharedApplication] setStatusBarHidden:fullScreen withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setToolbarHidden:fullScreen animated:YES];
    if (fullScreen) [self darkenBackground];
    else [self brightenBackground];
    [self setNavigationBarHidden:fullScreen animated:YES];
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return PHOTO_SPACING;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.frame.size.width - PHOTO_SPACING;
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
            [self setFullScreen:YES];
        } else {
            shouldHideNavigationBar = NO;
        }
        
        self.previousPage = page;
        Photo *photo = [self.dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0]];
        if (self.delegate && [self.delegate respondsToSelector:@selector(photosHorizontalScrollingViewController:didChangePage:item:)]) {
            [self.delegate photosHorizontalScrollingViewController:self didChangePage:page item:photo];
            [self showLoadingBarButtonItem:NO];
        }
        // this is to fix the very weird bug  in iPhone 6plus where cannot change page after double tap to max zoom
        PhotoZoomableCell *cell = [self currentCell];
        [cell setImageSize:CGSizeMake(photo.normalImage.width.floatValue, photo.normalImage.height.floatValue)];
        [cell centerScrollViewContents];
        // end of fix
    }
}

- (NSInteger)currentCollectionViewPage:(UIScrollView *)scrollView{
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelDismissViewController:)]) {
        [self.delegate cancelDismissViewController:self];
    }
}

- (void)didReachPercentageToClosePhotosHorizontalViewController {
    PBX_LOG(@"Popping from horizontal view controller");
    [[self currentCell] setClosingViewController:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldClosePhotosHorizontalViewController:)]) {
        [self.delegate shouldClosePhotosHorizontalViewController:self];
    }
}

- (void)didDragDownWithPercentage:(float)progress {
    CGFloat alpha = MIN(1-progress+0.2, 1);
    [self.darkBackgroundView setAlpha:alpha];
    if (progress > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(willDismissViewController:)]) {
            [self.delegate willDismissViewController:self];
        }
    }
}

#pragma mark - Button

- (void)infoButtonTapped:(id)sender {
    [sender setEnabled:NO];
    
    PhotoInfoViewController *photoInfo = [[PhotoInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [photoInfo setPhoto:[[self currentCell] item]];
    [photoInfo setDelegate:self];
    [photoInfo setModalPresentationStyle:UIModalPresentationCustom];
    if (!self.transitionToInfoDelegate) {
        self.transitionToInfoDelegate = [[TransitionToInfoDelegate alloc] init];
    }
    [photoInfo setTransitioningDelegate:self.transitionToInfoDelegate];
    
    [self presentViewController:photoInfo animated:YES completion:^{
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

- (void)favoriteButtonTapped:(id)sender {
    [sender setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[FavoritesManager sharedManager] addPhoto:[self currentPhoto]];
        
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Saved to Favorites", nil)];
        
        [self showLoadingBarButtonItem:NO];
    });
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
        [[NPRNotificationManager sharedManager] postNotificationWithImage:nil position:NPRNotificationPositionBottom type:NPRNotificationTypeSuccess string:NSLocalizedString(@"Download has started", nil) accessoryType:NPRNotificationAccessoryTypeNone accessoryView:nil duration:1 onTap:nil];
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
    [[PhotoSharingManager sharedManager] sharePhoto:photo image:cell.thisImageview.image fromViewController:self tokenFetchedBlock:^(id token) {
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
    UIBarButtonItem *favoriteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star.png"] style:UIBarButtonItemStylePlain target:self action:@selector(favoriteButtonTapped:)];
    if ([[FavoritesManager sharedManager] photoHasBeenDownloaded:[self currentPhoto]]) {
        [favoriteButton setImage:[UIImage imageNamed:@"star-fill.png"]];
    }
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info.png"] style:UIBarButtonItemStylePlain target:self action:@selector(infoButtonTapped:)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *shareButton;
    
    if (show) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [indicatorView setColor:[[[[UIApplication sharedApplication] delegate] window] tintColor]];
        shareButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
        [indicatorView startAnimating];
    } else {
        shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
    }
    if (!self.hideDownloadButton) {
        [self setToolbarItems:@[shareButton, space, rightButton, space, favoriteButton, space, infoButton]];
    }
    else [self setToolbarItems:@[shareButton, space, favoriteButton, space, infoButton]];
}

#pragma mark - Custom Animation Transition Delegate

- (PhotoZoomableCell *)currentCell {
    return [[self.collectionView visibleCells] firstObject];
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
    [photoInfo dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)photoInfoViewController:(PhotoInfoViewController *)photoInfo didDragToClose:(CGFloat)progress {
    [[[self currentCell] grayImageView] setAlpha:1-progress];
}

#pragma mark - TransitionToInfoPresentationControllerPresentingDelegate

- (void)willAnimateAlongTransitionToPresentInfoController:(id)presentationController {
    [[self currentCell] setGrayscale:YES];
}

- (void)animateAlongTransitionToPresentInfoController:(id)presentationController{
    [self setFullScreen:YES];
    [[self currentCell] setZoomToFillScreen:YES];
}

- (void)dismissAlongTransitionToInfoController:(id)presentationController {
    [[self currentCell] setGrayscale:NO];
    [[self currentCell] setZoomToFillScreen:NO];
}

- (void)didFinishDismissAnimationFromInfoControllerPresentationController:(id)presentationController {
}

#pragma mark - Alert 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self continueDownloadOriginalImage];
    }
}

@end

@implementation PhotosHorizontalLayout

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    if (self.targetIndexPath) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:self.targetIndexPath];
        return CGPointMake(attr.frame.origin.x, 0);
    }
    return proposedContentOffset;
}

@end
