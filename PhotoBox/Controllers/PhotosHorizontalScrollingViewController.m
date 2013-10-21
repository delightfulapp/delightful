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

@interface PhotosHorizontalScrollingViewController () <UIGestureRecognizerDelegate, PhotoZoomableCellDelegate> {
    BOOL shouldHideNavigationBar;
}

@property (nonatomic, assign) NSInteger previousPage;
@property (nonatomic, assign) BOOL justOpened;
@property (nonatomic, strong) UIView *darkBackgroundView;

@end

@implementation PhotosHorizontalScrollingViewController

- (void)viewDidLoad
{
    [self adjustCollectionViewWidthToHavePhotosSpacing];
    
    self.disableFetchOnLoad = YES;
    [super viewDidLoad];
    
    self.previousPage = 0;
    self.justOpened = YES;
	
    [self.collectionView setAlwaysBounceVertical:NO];
    [self.collectionView setAlwaysBounceHorizontal:YES];
    [self.collectionView setPagingEnabled:YES];
    
    [self.dataSource setCellIdentifier:[self cellIdentifier]];
    
    [self.collectionView reloadData];
    
    [self.navigationController.interactivePopGestureRecognizer setDelegate:self];
    
    UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce:)];
    [tapOnce setDelegate:self];
    [tapOnce setNumberOfTapsRequired:1];
    [self.collectionView addGestureRecognizer:tapOnce];
    
    [self showLoadingBarButtonItem:NO];
    
    self.darkBackgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.darkBackgroundView setBackgroundColor:[UIColor blackColor]];
    [self.darkBackgroundView setAlpha:0];
    [self.collectionView setBackgroundView:self.darkBackgroundView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self scrollToFirstShownPhoto];
    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:self.collectionView afterDelay:1];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
}

- (void)adjustCollectionViewWidthToHavePhotosSpacing {
    self.collectionView.frame = ({
        CGRect frame = self.collectionView.frame;
        frame.size.width += PHOTO_SPACING;
        frame;
    });
    self.collectionView.contentInset = ({
        UIEdgeInsets inset = self.collectionView.contentInset;
        inset.right += PHOTO_SPACING;
        inset;
    });
}

- (void)scrollToFirstShownPhoto {
    if ([self.dataSource numberOfItems]>self.firstShownPhotoIndex) {
        shouldHideNavigationBar = YES;
        self.previousPage = self.firstShownPhotoIndex-1;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.firstShownPhotoIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    } else {
        NSLog(@"Error scroll to first shown photo. Number of items = %d. First shown index = %d.", [self.dataSource numberOfItems], self.firstShownPhotoIndex);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (ResourceType)resourceType {
    return PhotoResource;
}

- (NSString *)resourceId {
    return self.item.itemId;
}

- (NSString *)relationshipKeyPathWithItem {
    return @"albums";
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
    };
    return configureCell;
}

#pragma mark - Interactive Gesture Recognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return NO;
    }
    return YES;
}

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
    if (self.navigationController.isNavigationBarHidden) {
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
                NSManagedObject *photo = [self.dataSource managedObjectItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0]];
                [self.delegate photosHorizontalScrollingViewController:self didChangePage:page item:photo];
            }
        } else {
            self.justOpened = NO;
        }
    }
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
    [self setBackgroundBrightness:1];
}

- (void)brightenBackground {
    [self setBackgroundBrightness:0];
}

- (void)setBackgroundBrightness:(float)brightness {
    [UIView animateWithDuration:0.4 animations:^{
        self.darkBackgroundView.alpha = brightness;
    }];
}

#pragma mark - Zoomable Cell delegate

- (void)didClosePhotosHorizontalViewController{
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)didDragDownWithPercentage:(float)progress {
    //[self.darkBackgroundView setAlpha:progress];
}

#pragma mark - Button

- (void)viewOriginalButtonTapped:(id)sender {
    if (![[NPRImageDownloader sharedDownloader] downloadViewControllerInitBlock]) {
        [[NPRImageDownloader sharedDownloader] setDownloadViewControllerInitBlock:^id{
            OriginalImageDownloaderViewController *original = [[OriginalImageDownloaderViewController alloc] initWithStyle:UITableViewStylePlain];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:original];
            return nav;
        }];
    }
    
    Photo *currentPhoto = (Photo *)[[self currentCell] item];
    
    if (currentPhoto.pathOriginal) {
        [[NPRImageDownloader sharedDownloader] queueImageURL:currentPhoto.pathOriginal thumbnail:[self currentCell].thisImageview.image];
    }
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
    [self.navigationItem setRightBarButtonItems:@[shareButton, rightButton]];
}

- (void)actionButtonTapped:(id)sender {
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

@end
