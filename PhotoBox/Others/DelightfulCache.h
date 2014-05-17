//
//  DelightfulCache.h
//  Delightful
//
//  Created by Nico Prananta on 5/17/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DelightfulCache : NSObject

+ (instancetype)sharedCache;

- (void)setObject:(id)object forKey:(id)aKey;

- (id)objectForKey:(id)aKey;


@end
