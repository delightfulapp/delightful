//
//  YapDataSource.m
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "YapDataSource.h"

#import "DLFDatabaseManager.h"

#import "Photo.h"

@interface YapDataSource ()

@end

@implementation YapDataSource

- (id)initWithCollectionView:(id)collectionView {
    self = [super initWithCollectionView:collectionView];
    if (self) {
        [self setupDatabase];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(yapDatabaseModified:)
                                                     name:YapDatabaseModifiedNotification
                                                   object:self.database];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectionIndex {
    NSInteger items = [self.selectedMappings numberOfItemsInSection:sectionIndex];
    return items;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.selectedMappings.numberOfSections;
}

- (NSString *)titleForSection:(NSInteger)section {
    return [self.selectedMappings groupForSection:section];
}

- (NSInteger)numberOfItems {
    __block NSInteger totalPhotosFetched;
    [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        totalPhotosFetched = [transaction numberOfKeysInCollection:photosCollectionName];
    }];
    return totalPhotosFetched;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    __block id item = nil;
    [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        item = [[transaction ext:self.selectedMappings.view] objectAtIndexPath:indexPath withMappings:self.selectedMappings];
    }];
    return item;
}

- (void)addItems:(NSArray *)items {
    if (items && items.count > 0) {
        [self.bgConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for (Photo *photo in items) {
                [transaction setObject:photo forKey:photo.photoId inCollection:photosCollectionName];
            }
        } completionBlock:^{
            NSLog(@"Done inserting to db");
        }];
    }
}

- (NSInteger)positionOfItemInIndexPath:(NSIndexPath *)indexPath {
    return [self.selectedMappings indexForRow:indexPath.row inSection:indexPath.section];
}

- (void)enumerateKeysAndObjectsInSection:(NSInteger)section usingBlock:(void (^)(NSString *, NSString *, id, NSUInteger, BOOL *))block {
    NSString *group = [self.selectedMappings groupForSection:section];
    [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [[transaction ext:self.selectedMappings.view] enumerateKeysAndObjectsInGroup:group usingBlock:block];
    }];
}

- (void)setSelectedMappings:(YapDatabaseViewMappings *)selectedMappings {
    if (_selectedMappings != selectedMappings) {
        _selectedMappings = selectedMappings;
        [self.mainConnection beginLongLivedReadTransaction];
        [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [_selectedMappings updateWithTransaction:transaction];
        }];
        [self.collectionView reloadData];
    }
}

- (void)setupDatabase {
    self.database = [[DLFDatabaseManager manager] currentDatabase];
    
    self.mainConnection = [self.database newConnection];
    self.bgConnection = [self.database newConnection];
    self.mainConnection.objectCacheLimit = 500; // increase object cache size
    self.mainConnection.metadataCacheEnabled = NO; // not using metadata on this connection
    
    self.bgConnection.objectCacheEnabled = NO; // don't need cache for write-only connection
    self.bgConnection.metadataCacheEnabled = NO;
        
    [self.mainConnection beginLongLivedReadTransaction];
}

- (void)yapDatabaseModified:(NSNotification *)notification {
    NSArray *notifications = [self.mainConnection beginLongLivedReadTransaction];
    
    if (![[self.mainConnection ext:self.selectedMappings.view] hasChangesForNotifications:notifications]) {
        [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [self.selectedMappings updateWithTransaction:transaction];
        }];
        return;
    }
    
    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    
    [[self.mainConnection ext:self.selectedMappings.view] getSectionChanges:&sectionChanges
                                                                 rowChanges:&rowChanges
                                                           forNotifications:notifications
                                                               withMappings:self.selectedMappings];
    if (sectionChanges.count == 0 && rowChanges.count == 0) {
        return;
    }
    
    NSLog(@"begin updates");
    [self.mainConnection beginLongLivedReadTransaction];
    
    [self.collectionView performBatchUpdates:^{
        for (YapDatabaseViewSectionChange *sectionChange in sectionChanges) {
            switch (sectionChange.type) {
                case YapDatabaseViewChangeDelete:{
                    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]];
                    break;
                }
                case YapDatabaseViewChangeInsert:{
                    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]];
                    break;
                }
                default:
                    break;
            }
        }
        
        
        for (YapDatabaseViewRowChange *rowChange in rowChanges) {
            switch (rowChange.type) {
                case YapDatabaseViewChangeDelete:{
                    [self.collectionView deleteItemsAtIndexPaths:@[rowChange.indexPath]];
                    break;
                }
                case YapDatabaseViewChangeInsert:{
                    [self.collectionView insertItemsAtIndexPaths:@[rowChange.newIndexPath]];
                    break;
                }
                case YapDatabaseViewChangeMove:{
                    [self.collectionView deleteItemsAtIndexPaths:@[rowChange.indexPath]];
                    [self.collectionView insertItemsAtIndexPaths:@[rowChange.newIndexPath]];
                    break;
                }
                case YapDatabaseViewChangeUpdate:{
                    [self.collectionView  reloadItemsAtIndexPaths:@[rowChange.indexPath]];
                    break;
                }
                default:
                    break;
            }
        }
    } completion:^(BOOL finished) {
        
    }];
    
    
}

@end
