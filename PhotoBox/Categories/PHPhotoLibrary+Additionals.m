//
//  PHPhotoLibrary+Additionals.m
//  Delightful
//
//  Created by  on 12/24/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "PHPhotoLibrary+Additionals.h"
#import "PHAsset+Additionals.h"

@implementation PHPhotoLibrary (Additionals)

- (BFTask *)deleteAsset:(PHAsset *)asset {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    [self performChanges:^{
        [PHAssetChangeRequest deleteAssets:@[asset]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            [taskCompletionSource setResult:asset];
        } else {
            [taskCompletionSource setError:error];
        }
    }];
    
    return taskCompletionSource.task;
}

- (BFTask *)deleteAssets:(NSArray *)phAssets {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    [self performChanges:^{
        [PHAssetChangeRequest deleteAssets:phAssets];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            [taskCompletionSource setResult:phAssets];
        } else {
            [taskCompletionSource setError:error];
        }
    }];
    return taskCompletionSource.task;
}

- (BFTask *)resizeAndCreateNewAsset:(PHAsset *)asset scale:(CGFloat)scale {
    return [[[asset fullResolutionImage] continueWithBlock:^id(BFTask *task) {
        UIImage *im = task.result;
        return [self resizeImage:im scale:scale];
    }] continueWithBlock:^id(BFTask *task) {
        BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
        UIImage *newImage = task.result;
        [self performChanges:^{
            
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:newImage];
            createAssetRequest.creationDate = asset.creationDate;
            createAssetRequest.location = asset.location;
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                [taskCompletionSource setResult:asset];
            } else {
                
                [taskCompletionSource setError:error];
            }
        }];
        
        return taskCompletionSource.task;
    }];
}

- (BFTask *)resizeAndDeleteAsset:(PHAsset *)asset scale:(CGFloat)scale {
    return [[[asset fullResolutionImage] continueWithBlock:^id(BFTask *task) {
        UIImage *im = task.result;
        
        return [self resizeImage:im scale:scale];
    }] continueWithBlock:^id(BFTask *task) {
        BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
        UIImage *newImage = task.result;
        [self performChanges:^{
            
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:newImage];
            createAssetRequest.creationDate = asset.creationDate;
            createAssetRequest.location = asset.location;
            [PHAssetChangeRequest deleteAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                [taskCompletionSource setResult:asset];
            } else {
                
                [taskCompletionSource setError:error];
            }
        }];
        
        return taskCompletionSource.task;
    }];
}

- (BFTask *)resizeImage:(UIImage *)image scale:(CGFloat)scale{
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect rect = CGRectMake(0,0,image.size.width * scale,image.size.height * scale);
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, image.scale);
        [image drawInRect:rect];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [taskCompletionSource setResult:newImage];
    });
    
    return taskCompletionSource.task;
}

- (PHAssetCollection*)albumWithTitle:(NSString*)title{
    // Check if album exists. If not, create it.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localizedTitle = %@", title];
    PHFetchOptions *options = [[PHFetchOptions alloc]init];
    options.predicate = predicate;
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:options];
    if(result.count){
        return result[0];
    }
    return nil;
    
}

@end
