//
//  DLFImageUploader.h
//  Delightful
//
//  Created by Nico Prananta on 6/14/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAsset;

extern NSString *const DLFAssetUploadProgressNotification;

extern NSString *const DLFAssetUploadDidChangeNumberOfUploadsNotification;

extern NSString *const DLFAssetUploadDidChangeNumberOfFailUploadsNotification;

extern NSString *const DLFAssetUploadDidSucceedNotification;

extern NSString *const kAssetURLKey;

extern NSString *const kProgressKey;

extern NSString *const kNumberOfUploadsKey;

@interface DLFImageUploader : NSObject

@property (nonatomic, assign, readonly) NSInteger numberOfUploading;

@property (nonatomic, assign, readonly) NSInteger numberOfFailUpload;

+ (instancetype)sharedUploader;

- (BOOL)queueAsset:(ALAsset *)asset;

@end
