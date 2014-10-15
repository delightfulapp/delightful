//
//  DLFDatabase.h
//  Delightful
//
//  Created by  on 9/23/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *photosCollectionName;
extern NSString *albumsCollectionName;
extern NSString *tagsCollectionName;

@class YapDatabase;

@interface DLFDatabaseManager : NSObject

+ (instancetype)manager;

- (YapDatabase *)currentDatabase;

- (void)removeAllItems;

@end
