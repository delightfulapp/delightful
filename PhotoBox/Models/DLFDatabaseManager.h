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

extern NSString *downloadedPhotosCollectionName;
extern NSString *favoritedPhotosCollectionName;

@class YapDatabase;
@class DLFYapDatabaseViewAndMapping;
@class PhotosCollection;

@interface DLFDatabaseManager : NSObject

+ (instancetype)manager;

- (int)numberOfPhotos;

- (YapDatabase *)currentDatabase;

- (void)removeAllItems;

- (void)removeAllPhotosWithCompletion:(void(^)())completion;

- (void)removePhotosInFlattenedView:(NSString *)viewName completion:(void(^)())completion;

+ (void)removeDatabase;

- (void)removeItemWithKey:(NSString *)key inCollection:(NSString *)collection;

- (void)saveFilteredViewName:(NSString *)viewName fromViewName:(NSString *)fromViewName filterName:(NSString *)filterName groupSortAsc:(BOOL)groupSortAsc objectKey:(NSString *)objectKey filterKey:(NSString *)filterKey;

@end
