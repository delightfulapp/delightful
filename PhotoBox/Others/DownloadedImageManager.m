//
//  DownloadedImageManager.m
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DownloadedImageManager.h"

#import "Photo.h"

#define kDownloadedImageManagerKey @"com.delightful.kDownloadedImageManagerKey"

@interface DownloadedImageManager ()

@property (nonatomic, strong) NSMutableOrderedSet *data;

@end

@implementation DownloadedImageManager

+ (instancetype)sharedManager {
    static DownloadedImageManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[DownloadedImageManager alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self downloadedImageKey]];
        if (data) {
            NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (arr) {
                [self.data addObjectsFromArray:arr];
            }
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (NSMutableOrderedSet *)data {
    if (!_data) {
        _data = [NSMutableOrderedSet orderedSet];
    }
    return _data;
}

- (void)addPhoto:(Photo *)photo {
    [photo setValue:[NSDate date] forKey:NSStringFromSelector(@selector(downloadedDate))];
    [self.data addObject:photo];
}

- (BOOL)photoHasBeenDownloaded:(Photo *)photo {
    return [self.data containsObject:photo];
}

- (void)appWillResignActive:(NSNotification *)notification {
    NSData *archived = [NSKeyedArchiver archivedDataWithRootObject:self.data.array];
    [[NSUserDefaults standardUserDefaults] setObject:archived forKey:[self downloadedImageKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)photos {
    return self.data.array;
}

- (void)clearHistory {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self downloadedImageKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.data removeAllObjects];
}

- (NSString *)downloadedImageKey {
    return kDownloadedImageManagerKey;
}

@end
