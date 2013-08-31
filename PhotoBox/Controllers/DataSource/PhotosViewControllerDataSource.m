//
//  PhotosViewControllerDataSource.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosViewControllerDataSource.h"

#import "NSArray+Additionals.h"

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

@end
