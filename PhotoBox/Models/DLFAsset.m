//
//  DLFAsset.m
//  Delightful
//
//  Created by  on 7/26/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DLFAsset.h"

@implementation DLFAsset

+ (NSArray *)assetsArrayFromALAssetArray:(NSArray *)array {
    NSMutableArray *dlfAssetArray = [NSMutableArray arrayWithCapacity:array.count];
    for (PHAsset *asset in array) {
        DLFAsset *a = [[DLFAsset alloc] init];
        a.asset = asset;
        [dlfAssetArray addObject:a];
    }
    return dlfAssetArray;
}

@end
