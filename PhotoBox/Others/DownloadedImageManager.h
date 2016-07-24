//
//  DownloadedImageManager.h
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Photo;

@class DLFYapDatabaseViewAndMapping;

@class YapDatabase;

@class YapDatabaseConnection;

@interface DownloadedImageManager : NSObject

+ (instancetype)sharedManager;

- (void)addPhoto:(Photo *)photo;

- (BOOL)photoHasBeenDownloaded:(Photo *)photo;

- (void)clearHistory;

- (DLFYapDatabaseViewAndMapping *)databaseViewMapping;

- (DLFYapDatabaseViewAndMapping *)flattenedDatabaseViewMapping;

+ (DLFYapDatabaseViewAndMapping *)databaseViewMappingWithDatabase:(id)database collectionName:(NSString *)collectionName connection:(YapDatabaseConnection *)connection viewName:(NSString *)viewName;

+ (NSString *)databaseViewName;

+ (NSString *)flattenedDatabaseViewName;

+ (NSString *)photosCollectionName;

@end
