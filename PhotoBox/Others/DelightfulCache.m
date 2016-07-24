//
//  DelightfulCache.m
//  Delightful
//
//  Created by Nico Prananta on 5/17/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "DelightfulCache.h"

#import "TMCache.h"

@implementation DelightfulCache

+ (instancetype)sharedCache {
    static DelightfulCache *_sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCache = [[DelightfulCache alloc] init];
    });
    
    return _sharedCache;
}

- (void)setObject:(id)object forKey:(id)aKey {
    if (object) {
        [[TMCache sharedCache] setObject:object forKey:aKey];
    } else {
        [[TMCache sharedCache] removeObjectForKey:aKey];
    }
}

- (id)objectForKey:(id)aKey {
    return [[TMCache sharedCache] objectForKey:aKey];
}

@end
