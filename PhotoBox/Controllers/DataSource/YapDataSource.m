//
//  YapDataSource.m
//  Delightful
//
//  Created by  on 9/28/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "YapDataSource.h"

#import "DLFDatabaseManager.h"

#import "Photo.h"

#import "DLFYapDatabaseViewAndMapping.h"

@interface YapDataSource ()

@end

@implementation YapDataSource

- (id)initWithCollectionView:(id)collectionView {
    self = [super initWithCollectionView:collectionView];
    if (self) {
        _pause = YES;
        [self setupDatabase];
        [self setupMapping];
        [self setDefaultMapping];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(yapDatabaseModified:)
                                                     name:YapDatabaseModifiedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeObservers];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)titleForSection:(NSInteger)section {
    return [self.selectedViewMapping.mapping groupForSection:section];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectionIndex {
    NSInteger items = [self.selectedViewMapping.mapping numberOfItemsInSection:sectionIndex];
    return items;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.selectedViewMapping.mapping.numberOfSections;
}

- (NSInteger)numberOfItems {
    __block NSInteger totalPhotosFetched;
    [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        totalPhotosFetched = [[transaction ext:self.selectedViewMapping.mapping.view] numberOfItemsInAllGroups];
    }];
    return totalPhotosFetched;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    __block id item = nil;
    [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        item = [[transaction ext:self.selectedViewMapping.mapping.view] objectAtIndexPath:indexPath withMappings:self.selectedViewMapping.mapping];
    }];
    return item;
}

- (NSIndexPath *)indexPathOfItem:(Photo *)item {
    __block NSIndexPath *indexPath;
    
    [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        indexPath = [[transaction ext:self.selectedViewMapping.mapping.view] indexPathForKey:item.photoId inCollection:photosCollectionName withMappings:self.selectedViewMapping.mapping];
    }];
    return indexPath;
}

- (void)addItems:(NSArray *)items {
    if (items && items.count > 0) {
        [self.bgConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for (Photo *photo in items) {
                [transaction setObject:photo forKey:photo.photoId inCollection:photosCollectionName];
            }
        } completionBlock:^{
            //CLS_LOG(@"Done inserting to db");
        }];
    }
}

- (NSInteger)positionOfItemInIndexPath:(NSIndexPath *)indexPath {
    return [self.selectedViewMapping.mapping indexForRow:indexPath.row inSection:indexPath.section];
}

- (void)enumerateKeysAndObjectsInSection:(NSInteger)section usingBlock:(void (^)(NSString *, NSString *, id, NSUInteger, BOOL *))block {
    NSString *group = [self.selectedViewMapping.mapping groupForSection:section];
    [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [[transaction ext:self.selectedViewMapping.mapping.view] enumerateKeysAndObjectsInGroup:group usingBlock:block];
    }];
}

#pragma mark - Setters

- (void)setSelectedViewMapping:(DLFYapDatabaseViewAndMapping *)selectedViewMapping {
    if (_selectedViewMapping != selectedViewMapping) {
        _selectedViewMapping = selectedViewMapping;
        [self.mainConnection beginLongLivedReadTransaction];
        __weak typeof (self) selfie = self;
        [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [selfie.selectedViewMapping.mapping updateWithTransaction:transaction];
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

- (void)setupMapping {
    
}

- (void)setDefaultMapping {
    
}

- (void)setPause:(BOOL)pause {
    if (_pause != pause) {
        _pause = pause;
    }
    if (!_pause) {
        [self.collectionView reloadData];
    }
}

#pragma mark - Notifications

- (void)yapDatabaseModified:(NSNotification *)notification {
    NSArray *notifications = [self.mainConnection beginLongLivedReadTransaction];
    
    if (![[self.mainConnection ext:self.selectedViewMapping.mapping.view] hasChangesForNotifications:notifications]) {
        [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [self.selectedViewMapping.mapping updateWithTransaction:transaction];
        }];
        return;
    }
    
    if (![self.mainConnection hasChangeForCollection:self.selectedViewMapping.collection inNotifications:notifications]) {
        return;
    }
    
    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    
    [[self.mainConnection ext:self.selectedViewMapping.mapping.view] getSectionChanges:&sectionChanges
                                                                 rowChanges:&rowChanges
                                                           forNotifications:notifications
                                                               withMappings:self.selectedViewMapping.mapping];
    if (sectionChanges.count == 0 && rowChanges.count == 0) {
        return;
    }
    
    //CLS_LOG(@"begin updates %@ section changes = %d rowchanges = %d", NSStringFromClass(self.class), (int)sectionChanges.count, (int)rowChanges.count);
    ////CLS_LOG(@"begin updates \n section changes %@ row changes %@", sectionChanges, rowChanges);
    
    void (^callDelegate)() = ^void() {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dataSourceDidModified:)]) {
            [self.delegate dataSourceDidModified:self];
        }
    };
    
    if (self.pause) {
        //[self.collectionView reloadData];
        callDelegate();
        return;
    }
    
    
    
    void (^performBatchUpdates)() = ^void() {
        [self.collectionView performBatchUpdates:^{
            for (YapDatabaseViewSectionChange *sectionChange in sectionChanges) {
                switch (sectionChange.type) {
                    case YapDatabaseViewChangeDelete:{
                        //CLS_LOG(@"section deleted: %lu", (unsigned long)sectionChange.index);
                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]];
                        break;
                    }
                    case YapDatabaseViewChangeInsert:{
                        //CLS_LOG(@"section inserted: %lu", (unsigned long)sectionChange.index);
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
                        if (rowChange.indexPath) [self.collectionView deleteItemsAtIndexPaths:@[rowChange.indexPath]];
                        break;
                    }
                    case YapDatabaseViewChangeInsert:{
                        if (rowChange.newIndexPath) [self.collectionView insertItemsAtIndexPaths:@[rowChange.newIndexPath]];
                        break;
                    }
                    case YapDatabaseViewChangeMove:{
                        if (rowChange.indexPath && rowChange.newIndexPath) {
                            [self.collectionView deleteItemsAtIndexPaths:@[rowChange.indexPath]];
                            [self.collectionView insertItemsAtIndexPaths:@[rowChange.newIndexPath]];
                        }
                        
                        break;
                    }
                    case YapDatabaseViewChangeUpdate:{
                        //if (rowChange.indexPath) [self.collectionView  reloadItemsAtIndexPaths:@[rowChange.indexPath]];
                        break;
                    }
                    default:
                        break;
                }
            }
        } completion:^(BOOL finished) {
            callDelegate();
        }];
    };
    
    if ([self.collectionView isDragging] || [self.collectionView isDecelerating] || [self.collectionView isTracking]) {
        //CLS_LOG(@"is dragging reloading data");
        [self.collectionView reloadData];
        callDelegate();
    } else {
        performBatchUpdates();
    }
}

@end
