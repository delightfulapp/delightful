//
//  CollectionViewDataSource.h
//  Expiry
//
//  Created by Nico Prananta on 7/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoBoxFetchedResultsController.h"

typedef void (^CollectionViewCellConfigureBlock)(id cell, id item);
typedef void (^CollectionViewHeaderCellConfigureBlock)(id cell, id item, NSIndexPath *indexPath);

@interface CollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) CollectionViewCellConfigureBlock configureCellBlock;
@property (nonatomic, strong) NSString *sectionHeaderIdentifier;
@property (nonatomic, copy) CollectionViewHeaderCellConfigureBlock configureCellHeaderBlock;
@property (nonatomic, assign) BOOL paused;

@property (nonatomic, strong) PhotoBoxFetchedResultsController *fetchedResultsController;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSManagedObject *)managedObjectItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathOfItem:(id)item;
- (NSInteger)positionOfItem:(id)item;
- (NSInteger)numberOfItems;

- (id)initWithCollectionView:(UICollectionView *)collectionView;

@end
