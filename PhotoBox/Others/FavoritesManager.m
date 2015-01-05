//
//  FavoritesManager.m
//  Delightful
//
//  Created by Nico Prananta on 5/12/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "FavoritesManager.h"
#import "DLFDatabaseManager.h"
#import "Photo.h"
#import "PhotoBoxClient.h"
#import <YapDatabase.h>
#import <YapDatabaseViewOptions.h>
#import <DLFYapDatabaseViewAndMapping.h>
#define kFavoritesManagerKey @"com.delightful.kFavoritesManagerKey"

NSString *const favoritesTagName = @"Favorites";

@implementation FavoritesManager

+ (instancetype)sharedManager {
    static FavoritesManager *_sharedFavoritesManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFavoritesManager = [[FavoritesManager alloc] init];
    });
    
    return _sharedFavoritesManager;
}

- (NSString *)downloadedImageKey {
    return kFavoritesManagerKey;
}

+ (NSString *)databaseViewName {
    return @"favorited-photos";
}

+ (NSString *)flattenedDatabaseViewName {
    return @"favorited-photos-flattened";
}

+ (NSString *)photosCollectionName {
    return favoritedPhotosCollectionName;
}

- (BFTask *)addPhoto:(Photo *)photo {
    __weak typeof (self) selfie = self;
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    [[PhotoBoxClient sharedClient] addFavoritePhoto:photo success:^(Photo *object) {
        [selfie savePhoto:object withCompletionBlock:^{
            [taskCompletionSource setResult:object];
        }];
    } failure:^(NSError *error) {
        [taskCompletionSource setError:error];
    }];
    return taskCompletionSource.task;
}

- (BFTask *)removePhoto:(Photo *)photo {
    __weak typeof (self) selfie = self;
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    [[PhotoBoxClient sharedClient] removeFavoritePhoto:photo success:^(id object) {
        [selfie savePhoto:object withCompletionBlock:^{
            [taskCompletionSource setResult:object];
        }];
    } failure:^(NSError *error) {
        [taskCompletionSource setError:error];
    }];
    return taskCompletionSource.task;
}

- (void)savePhoto:(Photo *)photo withCompletionBlock:(void(^)())completion {
    [[[DLFDatabaseManager manager] writeConnection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        Photo *savedPhoto = [transaction objectForKey:photo.photoId inCollection:photosCollectionName];
        if (savedPhoto) {
            [savedPhoto setValue:photo.tags forKey:NSStringFromSelector(@selector(tags))];
        }
        [transaction setObject:savedPhoto forKey:photo.photoId inCollection:photosCollectionName];
    } completionBlock:^{
        if (completion) {
            completion();
        }
    }];
}

- (BOOL)photoHasBeenFavorited:(Photo *)photo {
    return [photo.tags containsObject:favoritesTagName];
}


+ (DLFYapDatabaseViewAndMapping *)databaseViewMappingWithDatabase:(id)database collectionName:(NSString *)collectionName connection:(YapDatabaseConnection *)connection viewName:(NSString *)viewName {
    YapDatabaseViewGrouping *grouping = [YapDatabaseViewGrouping withObjectBlock:^NSString *(NSString *collection, NSString *key, Photo *object) {
        if (![collection isEqualToString:photosCollectionName]) {
            return nil;
        }
        BOOL include = NO;
        if ([object.tags containsObject:favoritesTagName]) {
            include = YES;
        }
        return (include)?@"":nil;
    }];
    
    YapDatabaseViewSorting *sorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, Photo *object1, NSString *collection2, NSString *key2, Photo *object2) {
        return [object2.dateTaken compare:object1.dateTaken];
    }];
    
    YapDatabaseViewOptions *option = [[YapDatabaseViewOptions alloc] init];
    [option setIsPersistent:YES];
    [option setAllowedCollections:[[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:photosCollectionName]]];
    
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGrouping:grouping sorting:sorting versionTag:@"2.0" options:option];
    
    DLFYapDatabaseViewAndMapping *(^viewMappingInit)() = ^DLFYapDatabaseViewAndMapping *() {
        YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
            return (group)?YES:NO;
        } sortBlock:^NSComparisonResult(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction) {
            return [group1 compare:group2];
        } view:viewName];
        
        DLFYapDatabaseViewAndMapping *returnObject = [[DLFYapDatabaseViewAndMapping alloc] init];
        returnObject.view = view;
        returnObject.mapping = mappings;
        returnObject.viewName = viewName;
        returnObject.isPersistent = YES;
        returnObject.collection = photosCollectionName;
        
        return returnObject;
    };
    
    if (![database registeredExtension:viewName]) {
        NSLog(@"registering extension %@", viewName);
        [database registerExtension:view withName:viewName];
    }
    
    return viewMappingInit();
}

@end
