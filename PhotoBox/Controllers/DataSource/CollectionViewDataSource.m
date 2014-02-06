//
//  CollectionViewDataSource.m
//  Expiry
//
//  Created by Nico Prananta on 7/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "CollectionViewDataSource.h"

#import "PhotoBoxCell.h"

@interface CollectionViewDataSource () {
    
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
    
    [self.collectionView reloadData];
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
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
    }
}

- (void)setPaused:(BOOL)paused {
    if (_paused != paused) {
        _paused = paused;
        if (paused) {
            self.fetchedResultsController.delegate = nil;
        } else {
            self.fetchedResultsController.delegate = self;
        }
    }
}

@end
