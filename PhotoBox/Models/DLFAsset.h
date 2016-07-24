//
//  DLFAsset.h
//  Delightful
//
//  Created by  on 7/26/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

@import Photos;
#import "Bolts.h"

@class Album;

@interface DLFAsset : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *tags;
@property (nonatomic, copy) NSArray *smartTags;
@property (nonatomic, strong) Album *album;
@property (nonatomic, assign) BOOL privatePhoto;
@property (nonatomic, assign) BOOL scaleAfterUpload;
@property (nonatomic, strong) NSString *photoTitle;
@property (nonatomic, strong) NSString *photoDescription;

+ (NSArray *)assetsArrayFromALAssetArray:(NSArray *)array;
- (BFTask *)prepareSmartTagsWithCIImage:(CIImage *)image;

@end
