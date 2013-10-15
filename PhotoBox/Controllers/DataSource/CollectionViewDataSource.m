//
//  CollectionViewDataSource.m
//  Expiry
//
//  Created by Nico Prananta on 7/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "CollectionViewDataSource.h"

@interface CollectionViewDataSource () <NSFetchedResultsControllerDelegate> {
}

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation CollectionViewDataSource

- (id)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        _collectionView.dataSource = self;
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectionIndex {
    id<NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[sectionIndex];
    return section.numberOfObjects;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.fetchedResultsController.sections.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // cache all the MTLModels so that itemAtIndexPath: will be fast
    for (int i = 0; i< self.fetchedResultsController.sections.count; i++) {
        for (int j=0; j<[self collectionView:self.collectionView numberOfItemsInSection:i]; j++) {
            @autoreleasepool {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
                [self itemAtIndexPath:indexPath];
            }
        }
    }
    [self.collectionView reloadData];
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
    NSAssert(_fetchedResultsController == nil, @"TODO: you can currently only assign this property once");
    _fetchedResultsController = fetchedResultsController;
    fetchedResultsController.delegate = self;
    [fetchedResultsController performFetch:NULL];
}

- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    if (paused) {
        self.fetchedResultsController.delegate = nil;
    } else {
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController performFetch:NULL];
        [self.collectionView reloadData];
    }
}

@end
