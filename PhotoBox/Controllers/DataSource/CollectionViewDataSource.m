//
//  CollectionViewDataSource.m
//  Expiry
//
//  Created by Nico Prananta on 7/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "CollectionViewDataSource.h"

#import "PhotoBoxCell.h"

#import "NSDate+Escort.h"

#import "DLFDatabaseManager.h"

#import "Photo.h"


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
    }
    return self;
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectionIndex {
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoBoxCell *cell = (PhotoBoxCell *)[collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *supplementaryView = (UICollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:self.sectionHeaderIdentifier forIndexPath:indexPath];
        if (self.configureCellHeaderBlock) {
            NSString *title = [self titleForSection:indexPath.section];
            self.configureCellHeaderBlock(supplementaryView, title, indexPath);
        }
        return supplementaryView;
    } else {
        UICollectionReusableView *supplementaryView = (UICollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:self.loadingFooterIdentifier forIndexPath:indexPath];
        return supplementaryView;
    }
    return nil;
}

#pragma mark - Items

- (NSInteger)numberOfItems {
    return 0;
}

- (NSIndexPath *)indexPathOfItem:(id)item {
    return nil;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)addItem:(id)item {
    [self addItems:@[item]];
}


- (void)addItems:(NSArray *)items {
    
}

- (NSInteger)positionOfItemInIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (void)enumerateKeysAndObjectsInSection:(NSInteger)section usingBlock:(void (^)(NSString *, NSString *, id, NSUInteger, BOOL *))block {
    
}

- (NSString *)titleForSection:(NSInteger)section {
    return nil;
}

@end
