//
//  DLFAsset.h
//  Delightful
//
//  Created by  on 7/26/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@class Album;

@interface DLFAsset : NSObject

@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, copy) NSString *tags;

@property (nonatomic, strong) Album *album;

@property (nonatomic, assign) BOOL privatePhoto;

+ (NSArray *)assetsArrayFromALAssetArray:(NSArray *)array;

@end
