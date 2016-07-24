//
//  DLFImageUploader.m
//  Delightful
//
//  Created by Nico Prananta on 6/14/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "DLFImageUploader.h"
#import "APIClient.h"
#import "DLFAsset.h"
#import "DLFDatabaseManager.h"
#import "PHPhotoLibrary+Additionals.h"
#import "YapDatabase.h"

@import Photos;

NSString *const DLFAssetUploadProgressNotification = @"com.getdelightfulapp.DLFAssetUploadProgressNotification";
NSString *const DLFAssetUploadDidChangeNumberOfUploadsNotification = @"com.getdelightfulapp.DLFAssetUploadDidChangeNumberOfUploadsNotification";
NSString *const DLFAssetUploadDidChangeNumberOfFailUploadsNotification = @"com.getdelightfulapp.DLFAssetUploadDidChangeNumberOfFailUploadsNotification";
NSString *const DLFAssetUploadDidSucceedNotification = @"com.getdelightfulapp.DLFAssetUploadDidSucceedNotification";
NSString *const DLFAssetUploadDidFailNotification = @"com.getdelightfulapp.DLFAssetUploadDidFailNotification";
NSString *const kAssetURLKey = @"com.getdelightfulapp.kAssetURLKey";
NSString *const kProgressKey = @"com.getdelightfulapp.kProgressKey";
NSString *const kAssetKey = @"com.getdelightfulapp.kAssetKey";
NSString *const kErrorKey = @"com.getdelightfulapp.kErrorKey";
NSString *const kNumberOfUploadsKey = @"com.getdelightfulapp.kNumberOfUploadsKey";
NSString *const kNumberOfFailUploadsKey = @"com.getdelightfulapp.kNumberOfFailUploadsKey";
NSString *const DLFAssetUploadDidQueueAssetNotification = @"com.getdelightfulapp.DLFAssetUploadDidQueueAssetNotification";

@interface DLFImageUploader ()

@property (nonatomic, strong) NSMutableArray *uploadingAssets;
@property (nonatomic, strong) NSMutableOrderedSet *uploadFailAssets;

@end

@implementation DLFImageUploader

+ (instancetype)sharedUploader {
    static DLFImageUploader *_sharedUploader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUploader = [[DLFImageUploader alloc] init];
    });
    
    return _sharedUploader;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uploadingAssets = [[NSMutableArray alloc] init];
        _uploadFailAssets = [[NSMutableOrderedSet alloc] init];
        
        
    }
    return self;
}

- (void)reloadUpload {
    NSArray *fails = [self.uploadFailAssets mutableCopy];
    [self clearFailUploads];
    for (DLFAsset *asset in fails) {
        [self queueAsset:asset];
    }
}

- (BOOL)queueAsset:(DLFAsset *)asset {
    if ([self isUploadingAsset:asset]) {
        return NO;
    }
    
    [self removeFailAsset:asset];
    [self addAsset:asset];
    __weak typeof (self) selfie = self;
    
    if (!self.uploadingTask || [self.uploadingTask isCancelled] || [self.uploadingTask isCompleted]) {
        self.uploadingTask = [BFTask taskWithResult:nil];
    }
    
    
    self.uploadingTask = [self.uploadingTask continueWithBlock:^id(BFTask *task) {
        BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
        
        [[APIClient sharedClient] uploadAsset:asset progress:^(float progress) {
            [selfie uploadProgress:progress asset:asset];
        } success:^(id object) {
            [selfie assetUploadDidSucceed:asset];
            [selfie removeFailAsset:asset];
            [taskCompletionSource setResult:asset];
            
        } failure:^(NSError *error) {
            [selfie assetUploadDidFail:asset error:error];
            [taskCompletionSource setError:error];
            
        }];
        return taskCompletionSource.task;
    }];
    
    return YES;
}

- (NSArray *)queuedAssets {
    return self.uploadingAssets;
}

- (NSArray *)failedAssets {
    return self.uploadFailAssets.array;
}

- (void)uploadProgress:(float)progress asset:(DLFAsset *)asset {
    [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadProgressNotification object:nil userInfo:@{kAssetURLKey: [asset.asset localIdentifier], kProgressKey: @(progress)}];
}

- (void)assetUploadDidSucceed:(DLFAsset *)asset {
    [self removeAsset:asset];
    [[[DLFDatabaseManager manager] writeConnection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:photoUploadedKey forKey:asset.asset.localIdentifier inCollection:uploadedCollectionName];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidSucceedNotification object:nil userInfo:@{kAssetKey: asset}];
}

- (void)assetUploadDidFail:(DLFAsset *)asset error:(NSError *)error {
    [self addFailAsset:asset];
    [self removeAsset:asset];
    [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidFailNotification object:nil userInfo:@{kAssetKey: asset, kErrorKey: error}];
    [[[DLFDatabaseManager manager] writeConnection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:photoUploadedFailedKey forKey:asset.asset.localIdentifier inCollection:uploadedCollectionName];
    }];
}

- (void)addAsset:(DLFAsset *)asset {
    @synchronized(self){
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfUploading))];
        [self.uploadingAssets addObject:asset];
        _numberOfUploading = self.uploadingAssets.count;
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfUploading))];
        [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil userInfo:@{kNumberOfUploadsKey: @(_numberOfUploading), kNumberOfFailUploadsKey:@(_numberOfFailUpload)}];
        [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidQueueAssetNotification object:nil userInfo:@{kAssetKey:asset}];
        
        [[[DLFDatabaseManager manager] writeConnection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction setObject:photoQueuedKey forKey:asset.asset.localIdentifier inCollection:uploadedCollectionName];
        }];
    }
}

- (void)removeAsset:(DLFAsset *)asset {
    @synchronized(self){
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfUploading))];
        [self.uploadingAssets removeObject:asset];
        _numberOfUploading = self.uploadingAssets.count;
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfUploading))];
        [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil userInfo:@{kNumberOfUploadsKey: @(_numberOfUploading), kNumberOfFailUploadsKey:@(_numberOfFailUpload)}];
    }
}

- (void)addFailAsset:(DLFAsset *)asset {
    @synchronized(self) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfFailUpload))];
        [self.uploadFailAssets addObject:asset];
        _numberOfFailUpload = self.uploadFailAssets.count;
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfFailUpload))];
        [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidChangeNumberOfFailUploadsNotification object:nil userInfo:@{kNumberOfFailUploadsKey: @(_numberOfFailUpload)}];
    }
}

- (void)removeFailAsset:(DLFAsset *)asset {
    @synchronized(self) {
        if ([self.uploadFailAssets containsObject:asset]) {
            [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfFailUpload))];
            [self.uploadFailAssets removeObject:asset];
            _numberOfFailUpload = self.uploadFailAssets.count;
            [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfFailUpload))];
            [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidChangeNumberOfFailUploadsNotification object:nil userInfo:@{kNumberOfFailUploadsKey: @(_numberOfFailUpload)}];
        }
    }
}

- (BOOL)isUploadingAsset:(DLFAsset *)asset {
    @synchronized(self){
        return [self.uploadingAssets containsObject:asset];
    }
}

- (void)clearFailUploads {
    @synchronized(self) {
        [self.uploadFailAssets removeAllObjects];
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfFailUpload))];
        _numberOfFailUpload = 0;
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfFailUpload))];
    }
}


@end
