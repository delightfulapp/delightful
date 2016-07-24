//
//  PHAsset+Additionals.m
//  Delightful
//
//  Created by  on 12/24/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "PHAsset+Additionals.h"

@implementation PHAsset (Additionals)

- (BFTask *)fullResolutionImage {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    PHContentEditingInputRequestOptions *editOptions = [[PHContentEditingInputRequestOptions alloc]init];
    editOptions.networkAccessAllowed = YES;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    [option setVersion:PHImageRequestOptionsVersionOriginal];
    [[PHImageManager defaultManager] requestImageDataForAsset:self options:option resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        CIImage *ciimage = [CIImage imageWithData:imageData];
        UIImage *image = [UIImage imageWithCIImage:ciimage scale:1.0 orientation:orientation];
        if (image) {
            [taskCompletionSource setResult:image];
        } else {
            [taskCompletionSource setError:[NSError errorWithDomain:@"phAsset" code:0 userInfo:info]];
        }
    }];
    
    return taskCompletionSource.task;
}

@end
