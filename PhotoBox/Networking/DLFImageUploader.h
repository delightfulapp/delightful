//
//  DLFImageUploader.h
//  Delightful
//
//  Created by Nico Prananta on 6/14/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bolts.h"

@class Album;
@class DLFAsset;

extern NSString *const DLFAssetUploadProgressNotification;
extern NSString *const DLFAssetUploadDidChangeNumberOfUploadsNotification;
extern NSString *const DLFAssetUploadDidChangeNumberOfFailUploadsNotification;
extern NSString *const DLFAssetUploadDidSucceedNotification;
extern NSString *const DLFAssetUploadDidFailNotification;
extern NSString *const DLFAssetUploadDidQueueAssetNotification;
extern NSString *const kAssetURLKey;
extern NSString *const kAssetKey;
extern NSString *const kErrorKey;
extern NSString *const kProgressKey;
extern NSString *const kNumberOfUploadsKey;
extern NSString *const kNumberOfFailUploadsKey;

@interface DLFImageUploader : NSObject

@property (nonatomic, assign, readonly) NSInteger numberOfUploading;
@property (nonatomic, assign, readonly) NSInteger numberOfFailUpload;
@property (nonatomic, strong) BFTask *uploadingTask;

+ (instancetype)sharedUploader;

- (BOOL)queueAsset:(DLFAsset *)asset;

- (void)reloadUpload;

- (void)clearFailUploads;

- (NSArray *)queuedAssets;

- (NSArray *)failedAssets;

@end
