//
//  PhotosViewControllerDataSource.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosViewControllerDataSource.h"

#import "NSArray+Additionals.h"

#import "PhotosSectionHeaderView.h"

@implementation PhotosViewControllerDataSource

- (void)setItems:(NSArray *)items {
    NSArray *groupedPhotos = [items groupedArrayBy:self.groupKey];
    super.items = groupedPhotos;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *group = self.items[indexPath.section];
    NSArray *members = [group objectForKey:@"members"];
    return [members objectAtIndex:indexPath.item];
}

- (NSIndexPath *)indexPathOfItem:(id)item {
    NSInteger section = 0;
    NSInteger row = 0;
    NSInteger i = 0;
    for (NSDictionary *dict in self.items) {
        if ([[dict objectForKey:self.groupKey] isEqualToString:[item valueForKey:self.groupKey]]) {
            section = i;
            NSArray *members = [dict objectForKey:@"members"];
            NSInteger index = [members indexOfObject:item];
            row = index;
            break;
        }
        i++;
    }
    return [NSIndexPath indexPathForItem:row inSection:section];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *group = self.items[section];
    NSArray *members = [group objectForKey:@"members"];
    return members.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PhotosSectionHeaderView *supplementaryView = (PhotosSectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:self.sectionHeaderIdentifier forIndexPath:indexPath];
    [supplementaryView setSection:indexPath.section];
    NSDictionary *group = self.items[indexPath.section];
    NSMutableDictionary *tempGroup = [NSMutableDictionary dictionaryWithDictionary:group];
    [tempGroup setObject:indexPath forKey:@"indexPath"];
    self.configureCellHeaderBlock(supplementaryView, tempGroup);
    return supplementaryView;
}

@end
