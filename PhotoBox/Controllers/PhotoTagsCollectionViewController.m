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

@interface PhotoTagsCollectionViewController () <UICollectionViewDelegateFlowLayout>

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    [cell setTags:asset.smartTags];
    
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
    PhotoTagsCell *cell = [[PhotoTagsCell alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(collectionView.frame), CGFLOAT_MAX)];
    DLFAsset *asset = self.assets[indexPath.item];
    [cell setTags:asset.smartTags];
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    CGFloat maxY = 0;
    for (UIView *subview in cell.contentView.subviews) {
        maxY = MAX(maxY, CGRectGetMaxY(subview.frame));
    }
    
    return CGSizeMake(CGRectGetWidth(collectionView.frame), maxY + 10);
}

@end
