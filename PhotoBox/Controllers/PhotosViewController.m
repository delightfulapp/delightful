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

#import "CollectionViewSelectCellGestureRecognizer.h"

#import "UIView+Additionals.h"
#import "NSString+Additionals.h"
#import "UIViewController+Additionals.h"

#import <JASidePanelController.h>
#import "UIViewController+DelightfulViewControllers.h"

#import "AppDelegate.h"

#import "DelightfulLayout.h"

#import "PhotosDataSource.h"

@interface PhotosViewController () <UICollectionViewDelegateFlowLayout, PhotosHorizontalScrollingViewControllerDelegate>

@property (nonatomic, strong) PhotoBoxCell *selectedCell;
@property (nonatomic, assign) CGRect selectedItemRect;
@property (nonatomic, strong) NSMutableDictionary *locationDictionary;
@property (nonatomic, strong) NSMutableDictionary *placemarkDictionary;
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

- (CollectionViewHeaderCellConfigureBlock)headerCellConfigureBlock {
    void (^configureCell)(PhotosSectionHeaderView*, id,NSIndexPath*) = ^(PhotosSectionHeaderView* cell, id item, NSIndexPath *indexPath) {
        [cell setHidden:(self.numberOfColumns==1)?YES:NO];
        [cell setTitleLabelText:[item localizedDate]];
        if ([self.placemarkDictionary objectForKey:@(indexPath.section)]) {
            [cell setLocation:[self.placemarkDictionary objectForKey:@(indexPath.section)]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)cellIdentifier {
    return @"photoCell";
}

- (NSString *)groupKey {
    return NSStringFromSelector(@selector(dateTakenString));
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

#pragma mark - Did something

- (void)willLoadItemsFromCoreData {
    DelightfulLayout *layout = (DelightfulLayout *)self.collectionView.collectionViewLayout;
    [layout updateLastIndexPath];
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
    int count = [self.dataSource numberOfItems];
    [self setPhotosCount:count max:self.totalItems];
    [self getLocationForEachSection];
}

- (void)didChangeNumberOfColumns {
    for (PhotoCell *cell in self.collectionView.visibleCells) {
        [cell setNumberOfColumns:self.numberOfColumns];
    }
}

- (void)showPinchGestureTipIfNeeded {
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
}

#pragma mark - Setters

- (void)setPhotosCount:(int)count max:(int)max{
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
    [destination setFirstShownPhoto:cell.item];
    [destination setFirstShownPhotoIndex:[self.dataSource positionOfItem:cell.item]];
    [destination setDelegate:self];
    [destination setRelationshipKeyPathWithItem:self.relationshipKeyPathWithItem];
    [destination setResourceType:self.resourceType];
    
    self.selectedCell = cell;
    [self setSelectedItemRectAtIndexPath:indexPath];
    
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

- (void)getLocationForEachSection {
    if (!self.locationDictionary) {
        self.locationDictionary = [NSMutableDictionary dictionary];
    }
    int i = 0;
    for (id<NSFetchedResultsSectionInfo> section in self.dataSource.fetchedResultsController.sections) {
        for (NSManagedObject *photo in section.objects) {
            NSNumber *latitude = [photo valueForKey:@"latitude"];
            NSNumber *longitude = [photo valueForKey:@"longitude"];
            if (latitude && ![latitude isKindOfClass:[NSNull class]] && longitude && ![longitude isKindOfClass:[NSNull class]]) {
                CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
                [self.locationDictionary setObject:location forKey:@(i)];
                break;
            }
        }
        i++;
    }
    
    for (NSNumber *section in self.locationDictionary.allKeys) {
        CLLocation *location = [self.locationDictionary objectForKey:section];
        [[LocationManager sharedManager] nameForLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error && placemarks.count > 0) {
                [self updateSectionHeader:[section integerValue] placemark:placemarks[0]];
            }
        }];
    }
}

- (void)updateSectionHeader:(NSInteger)section placemark:(CLPlacemark *)placemark {
    if (!self.placemarkDictionary) {
        self.placemarkDictionary = [NSMutableDictionary dictionary];
    }
    if (placemark) {
        [self.placemarkDictionary setObject:placemark forKey:@(section)];
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotoBoxLocationPlacemarkDidFetchNotification object:@{@"placemark": placemark, @"section":@(section)}];
    }
}

@end
