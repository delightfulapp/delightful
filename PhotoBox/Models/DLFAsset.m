//
//  DLFAsset.m
//  Delightful
//
//  Created by  on 7/26/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "DLFAsset.h"
#import "LocationManager.h"
#import "UIDevice+Additionals.h"
#import "TDImageColors.h"

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

- (BFTask *)prepareSmartTagsWithCIImage:(CIImage *)image {
    BFTask *locationTask = [[[[LocationManager sharedManager] nameForLocation:self.asset.location] continueWithBlock:^id(BFTask *task) {
        CLPlacemark *placemark = [((NSArray *)task.result) firstObject];
        NSMutableArray *tags = [NSMutableArray array];
        NSString *name = placemark.name;
        if (name) {
            if ([name rangeOfString:@","].location==NSNotFound) {
                [tags addObject:name];
            } else {
                NSArray *nameComponents = [name componentsSeparatedByString:@","];
                for (NSString *component in nameComponents) {
                    NSString *trimmed = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if (trimmed && trimmed.length > 0) {
                        [tags addObject:trimmed];
                    }
                }
            }
        }
        NSString *country = placemark.country;
        if (country) [tags addObject:country];
        NSString *city = placemark.locality;
        if (city) {
            if ([city rangeOfString:@","].location==NSNotFound) {
                [tags addObject:city];
            } else {
                NSArray *cityComponents = [city componentsSeparatedByString:@","];
                for (NSString *component in cityComponents) {
                    NSString *trimmed = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if (trimmed && trimmed.length > 0) {
                        [tags addObject:trimmed];
                    }
                }
            }
        }
        return [BFTask taskWithResult:tags];
    }] continueWithBlock:^id(BFTask *task) {
        NSMutableArray *tags = [((NSArray *)task.result) mutableCopy];
        if (!tags) {
            tags = [NSMutableArray array];
        }
        NSDictionary *metadata = image.properties;
        NSDictionary *exif = metadata[(NSString *)kCGImagePropertyExifDictionary];
        if (exif) {
            NSString *lensModel = exif[(NSString *)kCGImagePropertyExifLensModel];
            if (lensModel) {
                if ([lensModel rangeOfString:@"front camera"].location != NSNotFound) {
                    [tags addObject:@"selfie"];
                }
            }
        }
        
        BOOL photoFromCamera = NO;
        if (exif) {
            NSString *lensModel = exif[(NSString *)kCGImagePropertyExifLensModel];
            if (lensModel) {
                photoFromCamera = YES;
            }
        }
        BOOL isScreenshot = NO;
        if (!photoFromCamera) {
            CGSize windowSize = [[UIApplication sharedApplication] keyWindow].frame.size;
            CGSize size = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
            if (CGSizeEqualToSize(size, windowSize)) {
                isScreenshot = YES;
            } else {
                for (NSValue *dimension in [UIDevice deviceDimensions]) {
                    if (CGSizeEqualToSize(size, [dimension CGSizeValue])) {
                        isScreenshot = YES;
                        break;
                    }
                }
            }
        }
        if (isScreenshot) {
            [tags addObject:@"screenshot"];
        }
        
        if (self.asset.mediaType == PHAssetMediaTypeImage && (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoHDR)) {
            [tags addObject:@"hdr"];
        }
        
        if (self.asset.mediaType == PHAssetMediaTypeImage && (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoPanorama)) {
            [tags addObject:@"panorama"];
        }
        
        NSDictionary *tiff = metadata[(NSString *)kCGImagePropertyTIFFDictionary];
        if (tiff) {
            NSString *cameraModel = tiff[(NSString *)kCGImagePropertyTIFFModel];
            if (cameraModel) {
                [tags addObject:cameraModel];
            }
        }
        
        return [BFTask taskWithResult:tags];
    }];
    
    return locationTask;
}


@end
