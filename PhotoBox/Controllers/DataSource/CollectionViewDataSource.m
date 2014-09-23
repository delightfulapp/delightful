//
//  CollectionViewDataSource.m
//  Expiry
//
//  Created by Nico Prananta on 7/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "CollectionViewDataSource.h"

#import "PhotoBoxCell.h"

#import <NSDate+Escort.h>
#import <YapDatabase.h>
#import <YapDatabaseView.h>
#import "DLFDatabaseManager.h"

#import "Photo.h"

NSString *dateUploadedLastViewName = @"date-uploaded-last-photos";
NSString *dateTakenLastViewName = @"date-taken-last-photos";
NSString *dateUploadedFirstViewName = @"date-uploaded-first-photos";
NSString *dateTakenFirstViewName = @"date-taken-first-photos";

@interface CollectionViewDataSource () {
    
}

@property (nonatomic, strong) YapDatabaseConnection *mainConnection;
@property (nonatomic, strong) YapDatabaseConnection *bgConnection;

@property (nonatomic, strong) YapDatabaseView *dateUploadedLastView;
@property (nonatomic, strong) YapDatabaseViewMappings *dateUploadedLastViewMappings;
@property (nonatomic, strong) YapDatabaseView *dateUploadedFirstView;
@property (nonatomic, strong) YapDatabaseViewMappings *dateUploadedFirstViewMappings;
@property (nonatomic, strong) YapDatabaseView *dateTakenLastView;
@property (nonatomic, strong) YapDatabaseViewMappings *dateTakenLastViewMappings;
@property (nonatomic, strong) YapDatabaseView *dateTakenFirstView;
@property (nonatomic, strong) YapDatabaseViewMappings *dateTakenFirstViewMappings;

@property (nonatomic, strong) YapDatabaseViewMappings *selectedMappings;
@property (nonatomic, strong) YapDatabase *database;

@property (nonatomic, strong) id collectionView;

@end

@implementation CollectionViewDataSource

- (id)initWithCollectionView:(id)collectionView {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        ((UICollectionView *)_collectionView).dataSource = self;
        
        [self setupDatabase];
    }
    return self;
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectionIndex {
    return [self.selectedMappings numberOfItemsInSection:sectionIndex];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.selectedMappings.numberOfSections;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoBoxCell *cell = (PhotoBoxCell *)[collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *supplementaryView = (UICollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:self.sectionHeaderIdentifier forIndexPath:indexPath];
    if (self.configureCellHeaderBlock) {
        NSString *title = [self.selectedMappings groupForSection:indexPath.section];
        self.configureCellHeaderBlock(supplementaryView, title, indexPath);
    }
    return supplementaryView;
}

#pragma mark - Items

- (NSInteger)numberOfItems {
    __block NSInteger totalPhotosFetched;
    [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        totalPhotosFetched = [transaction numberOfKeysInCollection:photosCollectionName];
    }];
    return totalPhotosFetched;
}

- (NSIndexPath *)indexPathOfItem:(id)item {
    
    return nil;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    __block id item = nil;
    [self.mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        item = [[transaction ext:self.selectedMappings.view] objectAtIndexPath:indexPath withMappings:self.selectedMappings];
    }];
    return item;
}

- (void)addItem:(id)item {
    [self addItems:@[item]];
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

#pragma mark - Database

- (void)setSelectedMappings:(YapDatabaseViewMappings *)selectedMappings {
    if (_selectedMappings != selectedMappings) {
        _selectedMappings = selectedMappings;
        
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
    
    self.dateUploadedLastView = [self databaseViewForKeyToCompare:NSStringFromSelector(@selector(dateUploadedString)) name:dateUploadedLastViewName asc:NO];
    self.dateUploadedLastViewMappings = [self databaseViewMappingsWithViewName:dateUploadedLastViewName asc:NO];
    self.dateUploadedFirstView = [self databaseViewForKeyToCompare:NSStringFromSelector(@selector(dateUploadedString)) name:dateUploadedFirstViewName asc:YES];
    self.dateUploadedFirstViewMappings = [self databaseViewMappingsWithViewName:dateUploadedFirstViewName asc:YES];
    
    self.dateTakenFirstView = [self databaseViewForKeyToCompare:NSStringFromSelector(@selector(dateTakenString)) name:dateTakenFirstViewName asc:YES];
    self.dateTakenFirstViewMappings = [self databaseViewMappingsWithViewName:dateTakenFirstViewName asc:YES];
    self.dateTakenLastView = [self databaseViewForKeyToCompare:NSStringFromSelector(@selector(dateTakenString)) name:dateTakenLastViewName asc:NO];
    self.dateTakenLastViewMappings = [self databaseViewMappingsWithViewName:dateTakenLastViewName asc:NO];
    
    [self.mainConnection beginLongLivedReadTransaction];
    
    [self setSelectedMappings:self.dateTakenLastViewMappings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseModified:)
                                                 name:YapDatabaseModifiedNotification
                                               object:self.database];
}

- (YapDatabaseView *)databaseViewForKeyToCompare:(NSString *)keyToCompare name:(NSString *)viewName asc:(BOOL)ascending {
    YapDatabaseViewBlockType groupingBlockType = YapDatabaseViewBlockTypeWithObject;
    YapDatabaseViewGroupingWithObjectBlock groupingBlock = ^NSString *(NSString *collection, NSString *key, id object) {
        Photo *photo = (Photo *)object;
        return [[photo valueForKey:keyToCompare] description];
    };
    YapDatabaseViewBlockType sortingBlockType = YapDatabaseViewBlockTypeWithObject;
    YapDatabaseViewSortingWithObjectBlock sortingBlock = ^NSComparisonResult(NSString *group,
                                                                             NSString *collection1, NSString *key1, id obj1,
                                                                             NSString *collection2, NSString *key2, id obj2){
        return (ascending)?[[obj1 valueForKey:keyToCompare] compare:[obj2 valueForKey:keyToCompare]]:[[obj2 valueForKey:keyToCompare] compare:[obj1 valueForKey:keyToCompare]];
    };
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
                                        groupingBlockType:groupingBlockType
                                             sortingBlock:sortingBlock
                                         sortingBlockType:sortingBlockType];
    [self.database registerExtension:view withName:viewName];
    return view;
}

- (YapDatabaseViewMappings *)databaseViewMappingsWithViewName:(NSString *)viewName asc:(BOOL)ascending {
    YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
        return YES;
    } sortBlock:^NSComparisonResult(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction) {
        return (ascending)?[group1 compare:group2]:[group2 compare:group1];
    } view:viewName];
    return mappings;
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
