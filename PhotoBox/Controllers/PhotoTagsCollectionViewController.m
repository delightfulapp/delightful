//
//  PhotoTagsCollectionViewController.m
//  Delightful
//
//  Created by  on 12/17/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotoTagsCollectionViewController.h"
#import "PhotoTagsCell.h"
#import "DLFAsset.h"
#import "SmartTagButton.h"
@import Photos;

@interface PhotoTagsCollectionViewController () <UICollectionViewDelegateFlowLayout, PhotoTagsCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *smartTagsDictionary;

@end

@implementation PhotoTagsCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Smart Tags", nil);
    [self.collectionView registerClass:[PhotoTagsCell class] forCellWithReuseIdentifier:reuseIdentifier];
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
    return UIEdgeInsetsMake(10, 0, 10, 0);
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoTagsViewController:didChangeSmartTagsForAsset:)]) {
        [self.delegate photoTagsViewController:self didChangeSmartTagsForAsset:selectedAsset];
    }
}

@end
