//
//  PHPhotoLibrary+Additionals.h
//  Delightful
//
//  Created by  on 12/24/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

@import Photos;
#import "Bolts.h"

@interface PHPhotoLibrary (Additionals)

- (BFTask *)deleteAsset:(PHAsset *)asset;
- (BFTask *)deleteAssets:(NSArray *)phAssets;
- (BFTask *)resizeAndCreateNewAsset:(PHAsset *)asset scale:(CGFloat)scale;
- (BFTask *)resizeAndDeleteAsset:(PHAsset *)asset scale:(CGFloat)scale;

@end
