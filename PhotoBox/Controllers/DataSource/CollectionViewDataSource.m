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

@property (nonatomic, copy) NSMutableOrderedSet *uniqueItems;

@property (nonatomic, copy) NSArray *shownItems;

@property (nonatomic, copy) NSArray *internalFlattenedItems;

@end

@implementation CollectionViewDataSource

- (id)initWithCollectionView:(id)collectionView {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        ((UICollectionView *)_collectionView).dataSource = self;
        _uniqueItems = [NSMutableOrderedSet orderedSet];
    }
    return self;
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectionIndex {
    return [self.shownItems[sectionIndex] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.shownItems.count;
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
        NSArray *group = self.items[indexPath.section];
        NSString *title = (self.groupKey)?[[group firstObject] valueForKey:self.groupKey]:nil;
        self.configureCellHeaderBlock(supplementaryView, title, indexPath);
    }
    return supplementaryView;
}

#pragma mark - Items

- (NSInteger)numberOfItems {
    NSInteger count = 0;
    for (NSArray *array in self.shownItems) {
        count += array.count;
    }
    return count;
}

- (NSIndexPath *)indexPathOfItem:(id)item {
    NSInteger groupIndex = 0;
    for (NSArray *group in self.shownItems) {
        NSInteger itemIndex = [group indexOfObject:item];
        if (itemIndex != NSNotFound) {
            return [NSIndexPath indexPathForItem:itemIndex inSection:groupIndex];
        }
        groupIndex++;
    }
    return nil;
}

- (NSInteger)positionOfItem:(id)item {
    NSInteger index = [self.internalFlattenedItems indexOfObject:item];
    return index;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.shownItems[indexPath.section][indexPath.item];
}

- (void)addItems:(NSArray *)items {
    if (items && items.count > 0) {
        [self.uniqueItems addObjectsFromArray:items];
        
        self.shownItems = [self processedItems];
        
        [self.collectionView reloadData];
        
        PBX_LOG(@"Number of items %d", self.flattenedItems.count);
    }
}

- (NSArray *)items {
    return self.shownItems;
}

- (NSArray *)flattenedItems {
    return self.internalFlattenedItems;
}

- (void)removeAllItems {
    self.shownItems = [NSArray array];
    [self.uniqueItems removeAllObjects];
}

- (NSArray *)processedItems {
    NSArray *processed = self.uniqueItems.array;
    if (self.predicate) {
        processed = [processed filteredArrayUsingPredicate:self.predicate];
    }
    
    BOOL groupKeyAscending = NO;
    if (self.sortDescriptors) {
        processed = [processed sortedArrayUsingDescriptors:self.sortDescriptors];
        if (self.groupKey) {
            NSSortDescriptor *sortDescriptor = [[self.sortDescriptors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key = %@", self.groupKey]] firstObject];
            if (sortDescriptor) {
                groupKeyAscending = sortDescriptor.ascending;
            }
        }
    }
    
    if (self.groupKey) {
        NSArray *groups = [processed valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@", self.groupKey]];
        groups = [groups sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:groupKeyAscending]]];
        NSMutableArray *groupedArray = [NSMutableArray array];
        for (NSString *groupString in groups) {
            NSArray *group = [processed filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@", self.groupKey, groupString]];
            if (group) {
                [groupedArray addObject:group];
            }
        }
        processed = groupedArray;
    } else {
        processed = [NSArray arrayWithObject:processed];
    }
    
    NSMutableArray *flat = [NSMutableArray array];
    for (id section in processed) {
        for (id item in section) {
            [flat addObject:item];
        }
    }
    self.internalFlattenedItems = flat;
    
    return processed;
}

@end
