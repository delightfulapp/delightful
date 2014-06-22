//
//  DLFImageUploader.m
//  Delightful
//
//  Created by Nico Prananta on 6/14/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DLFImageUploader.h"

#import "PhotoBoxClient.h"

#import <AssetsLibrary/AssetsLibrary.h>

NSString *const DLFAssetUploadProgressNotification = @"com.getdelightfulapp.DLFAssetUploadProgressNotification";

NSString *const DLFAssetUploadDidChangeNumberOfUploadsNotification = @"com.getdelightfulapp.DLFAssetUploadDidChangeNumberOfUploadsNotification";

NSString *const DLFAssetUploadDidChangeNumberOfFailUploadsNotification = @"com.getdelightfulapp.DLFAssetUploadDidChangeNumberOfFailUploadsNotification";

NSString *const DLFAssetUploadDidSucceedNotification = @"com.getdelightfulapp.DLFAssetUploadDidSucceedNotification";

NSString *const kAssetURLKey = @"com.getdelightfulapp.kAssetURLKey";

NSString *const kProgressKey = @"com.getdelightfulapp.kProgressKey";

NSString *const kNumberOfUploadsKey = @"com.getdelightfulapp.kNumberOfUploadsKey";

@interface DLFImageUploader ()

@property (nonatomic, strong) NSMutableArray *uploadingAssets;

@property (nonatomic, strong) NSMutableArray *uploadFailAssets;

@end

@implementation DLFImageUploader

+ (instancetype)sharedUploader {
    static DLFImageUploader *_sharedUploader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUploader = [[DLFImageUploader alloc] init];
        _sharedUploader.uploadingAssets = [[NSMutableArray alloc] init];
        _sharedUploader.uploadFailAssets = [[NSMutableArray alloc] init];
    });
    
    return _sharedUploader;
}

- (BOOL)queueAsset:(ALAsset *)asset {
    if ([self isUploadingAsset:asset]) {
        return NO;
    }
    
    [self addAsset:asset];
    __weak typeof (self) selfie = self;
    [[PhotoBoxClient sharedClient] uploadPhoto:asset progress:^(float progress) {
        [selfie uploadProgress:progress asset:asset];
    } success:^(id object) {
        [selfie assetUploadDidSucceed:asset];
    } failure:^(NSError *error) {
        [selfie assetUploadDidFail:asset error:error];
    }];
    
    return YES;
}

- (void)uploadProgress:(float)progress asset:(ALAsset *)asset {
    [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadProgressNotification object:nil userInfo:@{kAssetURLKey: [asset valueForProperty:ALAssetPropertyAssetURL], kProgressKey: @(progress)}];
}

- (void)assetUploadDidSucceed:(ALAsset *)asset {
    [self removeAsset:asset];
    [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidSucceedNotification object:nil userInfo:@{kAssetURLKey: [asset valueForProperty:ALAssetPropertyAssetURL]}];
}

- (void)assetUploadDidFail:(ALAsset *)asset error:(NSError *)error {
    [self removeAsset:asset];
}

- (void)addAsset:(ALAsset *)asset {
    @synchronized(self){
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfUploading))];
        [self.uploadingAssets addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
        _numberOfUploading = self.uploadingAssets.count;
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfUploading))];
        [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil userInfo:@{kNumberOfUploadsKey: @(_numberOfUploading)}];
    }
}

- (void)removeAsset:(ALAsset *)asset {
    @synchronized(self){
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfUploading))];
        [self.uploadingAssets removeObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
        _numberOfUploading = self.uploadingAssets.count;
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfUploading))];
        [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil userInfo:@{kNumberOfUploadsKey: @(_numberOfUploading)}];
    }
}

- (void)addFailAsset:(ALAsset *)asset {
    @synchronized(self) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfFailUpload))];
        [self.uploadFailAssets addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
        _numberOfFailUpload = self.uploadFailAssets.count;
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfFailUpload))];
        [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidChangeNumberOfFailUploadsNotification object:nil userInfo:@{kNumberOfUploadsKey: @(_numberOfFailUpload)}];
    }
}

- (void)removeFailAsset:(ALAsset *)asset {
    @synchronized(self) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfFailUpload))];
        [self.uploadFailAssets removeObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
        _numberOfFailUpload = self.uploadFailAssets.count;
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfFailUpload))];
        [[NSNotificationCenter defaultCenter] postNotificationName:DLFAssetUploadDidChangeNumberOfFailUploadsNotification object:nil userInfo:@{kNumberOfUploadsKey: @(_numberOfFailUpload)}];
    }
}

- (BOOL)isUploadingAsset:(ALAsset *)asset {
    @synchronized(self){
        NSURL *URL = [asset valueForProperty:ALAssetPropertyAssetURL];
        return [self.uploadingAssets containsObject:URL];
    }
}

@end
