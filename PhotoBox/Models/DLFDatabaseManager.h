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
@class DLFYapDatabaseViewAndMapping;

@interface DLFDatabaseManager : NSObject

+ (instancetype)manager;

- (int)numberOfPhotos;

- (YapDatabase *)currentDatabase;

- (void)removeAllItems;

+ (void)removeDatabase;

- (void)saveFilteredViewName:(NSString *)viewName fromViewName:(NSString *)fromViewName filterName:(NSString *)filterName groupSortAsc:(BOOL)groupSortAsc objectKey:(NSString *)objectKey filterKey:(NSString *)filterKey;

@end
