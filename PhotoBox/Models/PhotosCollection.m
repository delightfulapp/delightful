//
//  PhotosCollection.m
//  Delightful
//
//  Created by Nico Prananta on 5/13/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosCollection.h"

#define PHOTOS_KEY @"com.delightful.photosCache"

#define MODELS_KEY @"MODELS_KEY"

#define MODELS_LAST_REFRESH_KEY @"MODELS_LAST_REFRESH_KEY"

#define MODELS_TOTAL_KEY @"MODELS_TOTAL_KEY"

#import <NSDate+Escort.h>

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

+ (void)setModelsCollection:(NSArray *)albums {
    if (!albums) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self.class modelsCollectionKey]];
    } else {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:albums];
        if (data) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:[self.class modelsCollectionKey]];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)modelsCollection {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self.class modelsCollectionKey]];
    if (!data) {
        return nil;
    }
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return array;
}

+ (void)setModelsCollectionLastRefresh:(NSDate *)date {
    if (!date) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self.class modelsRefreshKey]];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:[self.class modelsRefreshKey]];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)needRefreshModelsCollection {
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:[self.class modelsRefreshKey]];
    if (!date) {
        return YES;
    }
    if ([[NSDate date] hoursAfterDate:date] >= 22) {
        return YES;
    }
    return NO;
}

+ (void)setTotalCountCollection:(NSInteger)totalCount {
    [[NSUserDefaults standardUserDefaults] setInteger:totalCount forKey:[self.class modelsTotalCountKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)totalCountCollection {
    return [[NSUserDefaults standardUserDefaults] integerForKey:[self.class modelsTotalCountKey]];
}

+ (NSString *)modelsCollectionKey {
    return [NSString stringWithFormat:@"%@-%@", MODELS_KEY, NSStringFromClass([self class])];
}

+ (NSString *)modelsRefreshKey {
    return [NSString stringWithFormat:@"%@-%@", MODELS_LAST_REFRESH_KEY, NSStringFromClass([self class])];
}

+ (NSString *)modelsTotalCountKey {
    return [NSString stringWithFormat:@"%@-%@", MODELS_TOTAL_KEY, NSStringFromClass([self class])];
}

@end
