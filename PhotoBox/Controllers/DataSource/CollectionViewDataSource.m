//
//  CollectionViewDataSource.m
//  Expiry
//
//  Created by Nico Prananta on 7/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "CollectionViewDataSource.h"

#import "PhotoBoxCell.h"

@interface CollectionViewDataSource () <NSFetchedResultsControllerDelegate> {
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
}

@property (nonatomic, strong) id collectionView;

@end

@implementation CollectionViewDataSource

- (id)initWithCollectionView:(id)collectionView {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        ((UICollectionView *)_collectionView).dataSource = self;
        
        _objectChanges = [NSMutableArray array];
        _sectionChanges = [NSMutableArray array];
        _paused = YES;
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController mantleObjectAtIndexPath:indexPath];
}

- (NSManagedObject *)managedObjectItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectionIndex {
    id<NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[sectionIndex];
    return section.numberOfObjects;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // There's a bug that causes the app crashes occasionally in photos page. The collection view receives layout attributes for a cell with an index path that does not exist. So we need to invalidate the layout (StickyHeaderFlowLayout in this case) according to http://stackoverflow.com/a/19378624
    [collectionView.collectionViewLayout invalidateLayout];
    return self.fetchedResultsController.sections.count;
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
        id<NSFetchedResultsSectionInfo>  section = self.fetchedResultsController.sections[indexPath.section];
        NSString *title = [section name];
        self.configureCellHeaderBlock(supplementaryView, title,indexPath);
    }
    return supplementaryView;
}

#pragma mark - NSFetchedResultsController

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.fetchedResultsController clearCache];
    [self.fetchedResultsController preLoadCache];
    CLS_LOG(@"[%@] Reloading collection view", self.debugName);
    [self.collectionView reloadData];
    return;
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || ((UICollectionView *)self.collectionView).window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        } else {
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:^(BOOL finished) {
                for (int i = 0; i< self.fetchedResultsController.sections.count; i++) {
                    for (int j=0; j<[self collectionView:self.collectionView numberOfItemsInSection:i]; j++) {
                        @autoreleasepool {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
                            [self itemAtIndexPath:indexPath];
                        }
                    }
                }
            }];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

#pragma mark - Getters

- (NSInteger)numberOfItems {
    NSInteger sections = [self numberOfSectionsInCollectionView:self.collectionView];
    NSInteger count = 0;
    for (NSInteger i=0; i<sections; i++) {
        count += [self collectionView:self.collectionView numberOfItemsInSection:i];
    }
    return count;
}

- (NSIndexPath *)indexPathOfItem:(id)item {
    return [self.fetchedResultsController indexPathForObject:item];
}

- (NSInteger)positionOfItem:(id)item {
    NSIndexPath *indexPath = [self indexPathOfItem:item];
    NSInteger position = 0;
    for (int i=0; i<indexPath.section+1; i++) {
        if (i==indexPath.section) {
            position += indexPath.item;
        } else {
            position += [self collectionView:self.collectionView numberOfItemsInSection:i];
        }
    }
    return position;
}

#pragma mark - Setters

- (void)setFetchedResultsController:(PhotoBoxFetchedResultsController*)fetchedResultsController
{
    if (_fetchedResultsController != fetchedResultsController) {
        _fetchedResultsController = fetchedResultsController;
        _paused = NO;
        _fetchedResultsController.delegate = self;
        [_fetchedResultsController performFetch:NULL];
        CLS_LOG(@"[%@] Reloading collection view", self.debugName);
        [self.collectionView reloadData];
    }
}

- (void)setPaused:(BOOL)paused {
    if (_paused != paused) {
        _paused = paused;
        if (paused) {
            CLS_LOG(@"[%@] Before pausing. Number of sections = %d", self.debugName, [self numberOfSectionsInCollectionView:self.collectionView]);
            CLS_LOG(@"[%@] Before pausing. Number of fetched objects = %d", self.debugName, self.fetchedResultsController.fetchedObjects.count);
            self.fetchedResultsController.delegate = nil;
        } else {
            self.fetchedResultsController.delegate = self;
            [self.fetchedResultsController performFetch:NULL];
            CLS_LOG(@"[%@] After unpausing. Number of sections = %d", self.debugName, [self numberOfSectionsInCollectionView:self.collectionView]);
            CLS_LOG(@"[%@] Reloading collection view", self.debugName);
            [self.collectionView reloadData];
        }
    }
}

@end
