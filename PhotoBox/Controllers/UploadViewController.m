//
//  UploadViewController.m
//  Delightful
//
//  Created by Nico Prananta on 6/21/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "UploadViewController.h"
#import "UploadAssetCell.h"
#import "UploadHeaderView.h"
#import "DLFImageUploader.h"
#import "DelightfulCache.h"
#import "UploadReloadView.h"
#import "DLFAsset.h"
#import "PureLayout.h"

@import Photos;

@interface UploadViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *internalUploads;
@property (nonatomic, strong) NSMutableArray *failUploads;
@property (nonatomic, weak) UploadReloadView *reloadView;
@property (nonatomic, weak) UIButton *reloadButton;
@property (nonatomic, weak) UIButton *cancelButton;

@end

@implementation UploadViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.internalUploads = [NSMutableArray arrayWithArray:[[DLFImageUploader sharedUploader] queuedAssets]];
    self.failUploads = [NSMutableArray arrayWithArray:[[DLFImageUploader sharedUploader] failedAssets]];
    for (DLFAsset *failAsset in self.failUploads) {
        if (![self.internalUploads containsObject:failAsset]) {
            [self.internalUploads addObject:failAsset];
        }
    }
    
    [self.collectionView registerClass:[UploadAssetCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    
    [self.collectionView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [self.collectionView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    [self.collectionView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
    [self.collectionView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgressNotification:) name:DLFAssetUploadProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDoneNotification:) name:DLFAssetUploadDidSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadNumberChangeNotification:) name:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didQueueAssetToUploadNotification:) name:DLFAssetUploadDidQueueAssetNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDidFailNotification:) name:DLFAssetUploadDidFailNotification object:nil];
    
    self.title = NSLocalizedString(@"Uploads", nil);
    if (self.internalUploads.count == 0) {
        [self showNoUploads:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.navigationController.viewControllers.count == 1) {
        [self.collectionView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height, 0, 0, 0)];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone target:self action:@selector(didTapCancelButton:)];
        [self.navigationItem setLeftBarButtonItem:cancelButton];
    }
}

- (void)reloadUpload {
    [[DLFImageUploader sharedUploader] reloadUpload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DLFAssetUploadProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DLFAssetUploadDidSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUploads:(NSArray *)uploads {
    if (_uploads != uploads) {
        _uploads = uploads;
        
        _internalUploads = [_uploads mutableCopy];
    }
}

- (void)showReloadButtons:(BOOL)show {
    if (show) {
        UploadReloadView *reloadView = [[UploadReloadView alloc] init];
        [reloadView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:reloadView];
        self.reloadView = reloadView;
        
        [reloadView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view];
        [reloadView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
        [reloadView autoCenterInSuperview];
        
        self.reloadButton = self.reloadView.reloadButton;
        self.cancelButton = self.reloadView.cancelButton;
    } else {
        [self.reloadView removeFromSuperview];
        self.reloadView = nil;
    }
}

- (void)showNoUploads:(BOOL)show {
    if (show) {
        UIView *whiteView = [[UIView alloc] initWithFrame:self.collectionView.frame];
        [whiteView setBackgroundColor:[UIColor whiteColor]];
        UILabel *textLabel = [[UILabel alloc] initForAutoLayout];
        [textLabel setText:NSLocalizedString(@"You have no active uploads.", nil)];
        [textLabel setTextColor:[UIColor grayColor]];
        [textLabel sizeToFit];
        [whiteView addSubview:textLabel];
        [textLabel autoCenterInSuperview];
        [textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:whiteView withOffset:20 relation:NSLayoutRelationGreaterThanOrEqual];
        [textLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:whiteView withOffset:-20 relation:NSLayoutRelationLessThanOrEqual];
        [self.collectionView setBackgroundView:whiteView];
    } else {
        [self.collectionView setBackgroundView:nil];
    }
}

#pragma mark - Getters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_collectionView setAlwaysBounceVertical:NO];
        [_collectionView setAlwaysBounceVertical:YES];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (NSString *)cellIdentifier {
    return @"uploadPhotoCell";
}

- (NSString *)headerIdentifier {
    return @"uploadHeaderIdentifier";
}

#pragma mark - Buttons

- (void)didTapCancelButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadViewControllerDidClose:)]) {
        [self.delegate uploadViewControllerDidClose:self];
    }
}

#pragma mark - Collection View Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UploadAssetCell *cell = (UploadAssetCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[self cellIdentifier] forIndexPath:indexPath];
    DLFAsset *asset = [self.internalUploads objectAtIndex:indexPath.item];
    [cell setItem:asset];
    
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    PHAsset *photo = asset.asset;
    [[PHCachingImageManager defaultManager] requestImageForAsset:photo targetSize:cell.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        if (cell.tag == currentTag) {
            cell.cellImageView.image = result;
        }
    }];
    
    if ([self.failUploads containsObject:asset]) {
        [cell setUploadProgress:0];
        [cell showReloadButton:YES];
    } else {
        [cell showReloadButton:NO];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UploadAssetCell *cell = (UploadAssetCell *)[collectionView cellForItemAtIndexPath:indexPath];
    DLFAsset *asset = (DLFAsset *)cell.item;
    
    if ([self.failUploads containsObject:asset]) {
        [[DLFImageUploader sharedUploader] queueAsset:asset];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int numberOfColumns = 3;
    CGFloat width = collectionView.frame.size.width - (numberOfColumns-1);
    CGFloat itemWidth = floorf(width/numberOfColumns);
    return CGSizeMake(itemWidth, itemWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.internalUploads.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - Upload observers

- (void)didQueueAssetToUploadNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    DLFAsset *asset = [userInfo objectForKey:kAssetKey];
    if (![self.internalUploads containsObject:asset]) {
        [self.internalUploads addObject:asset];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.internalUploads.count-1 inSection:0]]];
    } else {
        NSInteger index = [self.internalUploads indexOfObject:asset];
        UploadAssetCell *cell = (UploadAssetCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        if (cell) {
            [cell showReloadButton:NO];
        }
    }
}

- (void)uploadNumberChangeNotification:(NSNotification *)notification {
    NSInteger numberOfUploads = [notification.userInfo[kNumberOfUploadsKey] integerValue];
    NSInteger numberOfFailUploads = [notification.userInfo[kNumberOfFailUploadsKey] integerValue];
    if (numberOfUploads==0 && numberOfFailUploads == 0) {
        self.title = NSLocalizedString(@"Uploading done", nil);
        [self showNoUploads:YES];
    } else if (numberOfUploads == 0 && numberOfFailUploads > 0) {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"%d uploads failed", nil), numberOfFailUploads];
        [self showNoUploads:NO];
    } else {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Uploading %1$d %2$@", nil), numberOfUploads, (numberOfUploads==1)?NSLocalizedString(@"photo", nil):NSLocalizedString(@"photos", nil)];
        [self showNoUploads:NO];
    }
}

- (void)uploadProgressNotification:(NSNotification *)notification {
    NSString *identifier = notification.userInfo[kAssetURLKey];
    
    for (UploadAssetCell *cell in self.collectionView.visibleCells) {
        DLFAsset *cellAsset = (DLFAsset *)cell.item;
        if ([[cellAsset.asset localIdentifier] isEqual:identifier]) {
            [cell setUploadProgress:[notification.userInfo[kProgressKey] floatValue]];
            break;
        }
    }
}

- (void)uploadDoneNotification:(NSNotification *)notification {
    DLFAsset *asset = notification.userInfo[kAssetKey];
    
    NSInteger index = [self.internalUploads indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(DLFAsset *obj, NSUInteger idx, BOOL *stop) {
        if ([[obj.asset localIdentifier] isEqualToString:asset.asset.localIdentifier]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    [self.failUploads removeObject:asset];
    
    if (index != NSNotFound) {
        [self.internalUploads removeObjectAtIndex:index];
        
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        } completion:^(BOOL finished) {
            if (self.internalUploads.count == 0) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(uploadViewControllerDidFinishUploading:)]) {
                    [self.delegate uploadViewControllerDidFinishUploading:self];
                }
            }
        }];
    }
}

- (void)uploadDidFailNotification:(NSNotification *)notification {
    DLFAsset *asset = notification.userInfo[kAssetKey];
    
    NSInteger index = [self.internalUploads indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(DLFAsset *obj, NSUInteger idx, BOOL *stop) {
        if ([[obj.asset localIdentifier] isEqualToString:asset.asset.localIdentifier]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (index != NSNotFound) {
        [self.failUploads addObject:asset];
        UploadAssetCell *cell = (UploadAssetCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        if (cell) {
            [cell setUploadProgress:0];
            [cell showReloadButton:YES];
        }
    }
}

@end
