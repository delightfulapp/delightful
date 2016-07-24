//
//  DLFDatabase.h
//  Delightful
//
//  Created by  on 9/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *photosCollectionName;
extern NSString *albumsCollectionName;
extern NSString *tagsCollectionName;
extern NSString *locationsCollectionName;
extern NSString *uploadedCollectionName;

extern NSString *photoUploadedKey;
extern NSString *photoQueuedKey;
extern NSString *photoUploadedFailedKey;

extern NSString *downloadedPhotosCollectionName;
extern NSString *favoritedPhotosCollectionName;

@class YapDatabase;
@class DLFYapDatabaseViewAndMapping;
@class PhotosCollection;
@class YapDatabaseConnection;

@interface DLFDatabaseManager : NSObject

@property (nonatomic, strong, readonly) YapDatabaseConnection *writeConnection;
@property (nonatomic, strong, readonly) YapDatabaseConnection *readConnection;

+ (instancetype)manager;

- (int)numberOfPhotos;

- (YapDatabase *)currentDatabase;

- (void)removeAllItems;

- (void)removeAllPhotosWithCompletion:(void(^)())completion;

- (void)removePhotosInFlattenedView:(NSString *)viewName completion:(void(^)())completion;

- (void)removeAlbumsCompletion:(void(^)())completion;

- (void)removeTagsCompletion:(void(^)())completion;

- (void)removeCollection:(Class)classCollection completion:(void(^)())completion;

+ (void)removeDatabase;

- (void)removeItemWithKey:(NSString *)key inCollection:(NSString *)collection;

- (void)tagsWithCompletion:(void(^)(NSArray *tags))completion;

- (NSArray *)tags;

- (void)saveFilteredViewName:(NSString *)viewName fromViewName:(NSString *)fromViewName filterName:(NSString *)filterName groupSortAsc:(BOOL)groupSortAsc objectKey:(NSString *)objectKey filterKey:(NSString *)filterKey;

@end
