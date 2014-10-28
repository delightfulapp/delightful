//
//  CollectionViewDataSource.h
//  Expiry
//
//  Created by Nico Prananta on 7/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CollectionViewCellConfigureBlock)(id cell, id item);
typedef void (^CollectionViewHeaderCellConfigureBlock)(id cell, id item, NSIndexPath *indexPath);

@interface CollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, copy) NSString *cellIdentifier;

@property (nonatomic, copy) CollectionViewCellConfigureBlock configureCellBlock;

@property (nonatomic, strong) NSString *sectionHeaderIdentifier;

@property (nonatomic, strong) NSString *loadingFooterIdentifier;

@property (nonatomic, copy) CollectionViewHeaderCellConfigureBlock configureCellHeaderBlock;

//for debugging purposes
@property (nonatomic, strong) NSString *debugName;

@property (nonatomic, strong) NSIndexPath *loadingViewIndexPath;

@property (nonatomic, strong, readonly) id collectionView;

- (void)addItems:(NSArray *)items;

- (void)addItem:(id)item;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)titleForSection:(NSInteger)section;

- (NSIndexPath *)indexPathOfItem:(id)item;

- (NSInteger)numberOfItems;

- (id)initWithCollectionView:(id)collectionView;

- (NSInteger)positionOfItemInIndexPath:(NSIndexPath *)indexPath;

- (void)enumerateKeysAndObjectsInSection:(NSInteger)section
                              usingBlock:(void (^)(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop))block;

@end
