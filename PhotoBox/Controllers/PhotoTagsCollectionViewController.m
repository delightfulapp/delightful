//
//  PhotoTagsCollectionViewController.m
//  Delightful
//
//  Created by  on 12/17/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "PhotoTagsCollectionViewController.h"
#import "PhotoTagsCell.h"
#import "DLFAsset.h"
#import "SmartTagButton.h"
#import "PureLayout.h"
#import "CSNotificationView.h"

@interface HeaderReusableView : UICollectionReusableView

@property (nonatomic, weak) UILabel *label;

@end

@implementation HeaderReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initForAutoLayout];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setNumberOfLines:0];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:NSLocalizedString(@"Tap the tag to add or remove it from the photo.", nil)];
        [self addSubview:label];
        [label autoCenterInSuperview];
        [label autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self withOffset:20 relation:NSLayoutRelationGreaterThanOrEqual];
        [label autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:-10 relation:NSLayoutRelationLessThanOrEqual];
        [label autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:10 relation:NSLayoutRelationGreaterThanOrEqual];
        [label autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-10 relation:NSLayoutRelationLessThanOrEqual];
        self.label = label;
    }
    return self;
}

@end

@import Photos;

@interface PhotoTagsCollectionViewController () <UICollectionViewDelegateFlowLayout, PhotoTagsCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *smartTagsDictionary;

@end

@implementation PhotoTagsCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const headerIdentifier = @"headerCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Smart Tags", nil);
    [self.collectionView registerClass:[PhotoTagsCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[HeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setAlwaysBounceVertical:YES];
    // Do any additional setup after loading the view.
}

- (void)setAssets:(NSArray *)assets {
    if (_assets != assets) {
        _assets = assets;
        
        if (!self.smartTagsDictionary) {
            self.smartTagsDictionary = [NSMutableDictionary dictionary];
        }
        
        for (DLFAsset *asset in _assets) {
            NSString *identifier = asset.asset.localIdentifier;
            NSArray *smartTags = asset.smartTags;
            NSMutableDictionary *thisAssetSmartTagsDictionary = [NSMutableDictionary dictionary];
            for (NSString *tag in smartTags) {
                [thisAssetSmartTagsDictionary setObject:@(YES) forKey:tag];
            }
            [self.smartTagsDictionary setObject:thisAssetSmartTagsDictionary forKey:identifier];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    } completion:nil];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoTagsCell *cell = (PhotoTagsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    DLFAsset *asset = self.assets[indexPath.item];
    [cell setLocalAssetIdentifier:asset.asset.localIdentifier];
    [cell setTagsDictionary:self.smartTagsDictionary[asset.asset.localIdentifier]];
    [cell setDelegate:self];
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    PHAsset *phAsset = asset.asset;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    [option setDeliveryMode:PHImageRequestOptionsDeliveryModeFastFormat];
    [[PHImageManager defaultManager] requestImageForAsset:phAsset
                                 targetSize:cell.imageViewSize
                                contentMode:PHImageContentModeAspectFill
                                    options:option
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  if (cell.tag == currentTag) {
                                      cell.imageView.image = result;
                                  }
                              }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    HeaderReusableView *reusableView = (HeaderReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    HeaderReusableView *headerView = [[HeaderReusableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(collectionView.frame), CGFLOAT_MAX)];
    [headerView.label setPreferredMaxLayoutWidth:CGRectGetWidth(collectionView.frame) - 20];
    [headerView setNeedsLayout];
    [headerView layoutIfNeeded];
    CGSize size = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return CGSizeMake(CGRectGetWidth(collectionView.frame), size.height);
}


#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.frame) - 20;
    PhotoTagsCell *cell = [[PhotoTagsCell alloc] initWithFrame:CGRectMake(0, 0, width, CGFLOAT_MAX)];
    DLFAsset *asset = self.assets[indexPath.item];
    [cell setLocalAssetIdentifier:asset.asset.localIdentifier];
    [cell setTagsDictionary:self.smartTagsDictionary[asset.asset.localIdentifier]];
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    CGFloat maxY = 0;
    for (UIView *subview in cell.contentView.subviews) {
        maxY = MAX(maxY, CGRectGetMaxY(subview.frame));
    }
    
    return CGSizeMake(width, maxY + 10);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 10, 0);
}

#pragma mark - <PhotoTagsCellDelegate>

- (void)cell:(PhotoTagsCell *)cell didTapButton:(SmartTagButton *)button {
    NSString *key = [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(asset)), NSStringFromSelector(@selector(localIdentifier))];
    DLFAsset *selectedAsset = [[self.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@", key, cell.localAssetIdentifier]] firstObject];
    NSMutableArray *smartTags = [selectedAsset.smartTags mutableCopy];
    BOOL smartTagIsIncluded = YES;
    if (button.tagState == TagStateSelected) {
        [smartTags removeObject:button.titleLabel.text];
        [button setTagState:TagStateNotSelected];
        smartTagIsIncluded = NO;
    } else {
        [smartTags addObject:button.titleLabel.text];
        [button setTagState:TagStateSelected];
    }
    [selectedAsset setSmartTags:smartTags];
    NSMutableDictionary *dict = [self.smartTagsDictionary[selectedAsset.asset.localIdentifier] mutableCopy];
    [dict setObject:(smartTagIsIncluded)?@(YES):@(NO) forKey:button.titleLabel.text];
    [self.smartTagsDictionary setObject:dict forKey:selectedAsset.asset.localIdentifier];
    
    if (smartTagIsIncluded) {
        [CSNotificationView showInViewController:self
                                       tintColor:[UIColor colorWithRed:0.000 green:0.6 blue:1.000 alpha:1]
                                            font:[UIFont systemFontOfSize:14]
                                   textAlignment:NSTextAlignmentCenter
                                           image:nil
                                         message:[NSString stringWithFormat:@"\"%@\" tag is added to photo.", button.titleLabel.text]
                                        duration:1.f];
    } else {
        [CSNotificationView showInViewController:self
                                       tintColor:[UIColor colorWithRed:0.931 green:0.598 blue:0.209 alpha:1.000]
                                            font:[UIFont systemFontOfSize:14]
                                   textAlignment:NSTextAlignmentCenter
                                           image:nil
                                         message:[NSString stringWithFormat:@"\"%@\" tag is removed from photo.", button.titleLabel.text]
                                        duration:1.f];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoTagsViewController:didChangeSmartTagsForAsset:)]) {
        [self.delegate photoTagsViewController:self didChangeSmartTagsForAsset:selectedAsset];
    }
}

@end
