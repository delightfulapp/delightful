//
//  PhotosCollection.m
//  Delightful
//
//  Created by Nico Prananta on 5/13/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosCollection.h"

#define PHOTOS_KEY @"com.delightful.photosCache"

@implementation PhotosCollection

@synthesize photos = _photos;
@synthesize totalPhotos = _totalPhotos;

#pragma mark - Cache

- (void)setTotalPhotos:(NSInteger)totalPhotos {
    _totalPhotos = totalPhotos;
    
    [[NSUserDefaults standardUserDefaults] setInteger:_totalPhotos forKey:[self totalPhotosCacheKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)totalPhotos {
    NSInteger total = _totalPhotos;
    if (total == 0) {
        total = [[NSUserDefaults standardUserDefaults] integerForKey:[self totalPhotosCacheKey]];
    }
    return total;
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    
    if (_photos) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_photos];
        if (data) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:[self cacheKey]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self cacheKey]];
    }
}

- (NSArray *)photos {
    if (!_photos) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self cacheKey]];
        if (data) {
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (array) {
                _photos = array;
            }
        }
    }
    return _photos;
}

- (NSString *)cacheKey {
    return [NSString stringWithFormat:@"%@-%@-%@", PHOTOS_KEY, NSStringFromClass([self class]), self.itemId];
}

- (NSString *)totalPhotosCacheKey {
    return [NSString stringWithFormat:@"TOTAL-%@", [self cacheKey]];
}

@end
